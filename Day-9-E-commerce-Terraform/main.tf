
# ==================================================
# LOCALS: SUBNET CONFIGURATION
# ==================================================

locals {
  subnets = {
    db_1a = {
      cidr = "10.0.0.0/24"
      az   = "a"
      tier = "database"
    }
    db_1b = {
      cidr = "10.0.1.0/24"
      az   = "b"
      tier = "database"
    }
    backend_1a = {
      cidr = "10.0.2.0/24"
      az   = "a"
      tier = "backend"
    }
    backend_1b = {
      cidr = "10.0.3.0/24"
      az   = "b"
      tier = "backend"
    }
    frontend_1a = {
      cidr = "10.0.4.0/24"
      az   = "a"
      tier = "frontend"
    }
    frontend_1b = {
      cidr = "10.0.5.0/24"
      az   = "b"
      tier = "frontend"
    }
    public_1a = {
      cidr = "10.0.6.0/24"
      az   = "a"
      tier = "public"
    }
    public_1b = {
      cidr = "10.0.7.0/24"
      az   = "b"
      tier = "public"
    }
  }
}

# ==================================================
# VPC
# ==================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-project-VPC"
  }
}

# ==================================================
# EIGHT SUBNETS
# ==================================================

resource "aws_subnet" "this" {
  for_each = local.subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = "${var.aws_region}${each.value.az}"

  map_public_ip_on_launch = each.value.tier == "public"

  tags = {
    Name = "${var.project_name}-${each.key}"
    Tier = each.value.tier
  }
}

# ==================================================
# INTERNET GATEWAY
# ==================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

# ==================================================
# PUBLIC ROUTE TABLE
# ==================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-RT"
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(["public_1a", "public_1b"])

  subnet_id      = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.public.id
}

# ==================================================
# NAT GATEWAY AND ELASTIC IP
# ==================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-NAT-EIP"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this["public_1a"].id

  tags = {
    Name = "${var.project_name}-NAT"
  }

  depends_on = [aws_internet_gateway.main]
}

# ==================================================
# PRIVATE APPLICATION ROUTE TABLE
# Frontend and backend use NAT for outbound access
# ==================================================

resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-app-RT"
  }
}

resource "aws_route_table_association" "private_app" {
  for_each = toset([
    "frontend_1a",
    "frontend_1b",
    "backend_1a",
    "backend_1b"
  ])

  subnet_id      = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.private_app.id
}

# ==================================================
# PRIVATE DATABASE ROUTE TABLE
# No internet default route
# ==================================================

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-database-RT"
  }
}

resource "aws_route_table_association" "database" {
  for_each = toset(["db_1a", "db_1b"])

  subnet_id      = aws_subnet.this[each.value].id
  route_table_id = aws_route_table.database.id
}

# ==================================================
# IAM ROLE FOR EC2 SESSION MANAGER
# ==================================================

resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.project_name}-EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-EC2-SSM-Role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "${var.project_name}-EC2-SSM-Profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ==================================================
# AMAZON LINUX 2023 AMI
# ==================================================

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ==================================================
# SECURITY GROUP: PUBLIC ALB
# HTTP PORT 80 ONLY FOR NOW
# ==================================================

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow public HTTP requests"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

# ==================================================
# SECURITY GROUP: FRONTEND
# Only ALB can reach frontend HTTP
# ==================================================

resource "aws_security_group" "frontend" {
  name   = "${var.project_name}-frontend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-frontend-sg"
  }
}

# ==================================================
# SECURITY GROUP: BACKEND
# Port 5000 only from frontend
# ==================================================

resource "aws_security_group" "backend" {
  name   = "${var.project_name}-backend-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "Backend application from frontend"
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-sg"
  }
}

# ==================================================
# SECURITY GROUP: DATABASE
# MySQL only from backend
# ==================================================

resource "aws_security_group" "database" {
  name   = "${var.project_name}-database-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description     = "MySQL from backend only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-database-sg"
  }
}

# ==================================================
# BACKEND EC2 INSTANCE
# PRIVATE SUBNET + SESSION MANAGER
# ==================================================

resource "aws_instance" "backend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.this["backend_1a"].id
  vpc_security_group_ids = [aws_security_group.backend.id]

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y python3
    systemctl enable --now amazon-ssm-agent

    cat > /opt/backend.py <<'PY'
    from http.server import BaseHTTPRequestHandler, HTTPServer

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(b'{"message":"E-commerce backend is running"}')

    HTTPServer(("0.0.0.0", 5000), Handler).serve_forever()
    PY

    cat > /etc/systemd/system/ecommerce-backend.service <<'SERVICE'
    [Unit]
    Description=E-commerce demo backend
    After=network.target

    [Service]
    ExecStart=/usr/bin/python3 /opt/backend.py
    Restart=always

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now ecommerce-backend
  EOF

  tags = {
    Name = "${var.project_name}-backend-server"
    Tier = "Backend"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}

# ==================================================
# FRONTEND EC2 INSTANCE
# PRIVATE SUBNET + SESSION MANAGER
# ==================================================

resource "aws_instance" "frontend" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.this["frontend_1a"].id
  vpc_security_group_ids = [aws_security_group.frontend.id]

  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    systemctl enable --now amazon-ssm-agent

    cat > /etc/nginx/conf.d/ecommerce.conf <<'NGINX'
    server {
        listen 80;
        server_name _;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }

        location /api/ {
            proxy_pass http://${aws_instance.backend.private_ip}:5000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
    NGINX

    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!doctype html>
    <html>
      <head><title>E-commerce</title></head>
      <body>
        <h1>Welcome to E-commerce</h1>
        <p>Frontend server is running.</p>
        <p><a href="/api/">Check backend API</a></p>
      </body>
    </html>
    HTML

    nginx -t && systemctl enable --now nginx
  EOF

  tags = {
    Name = "${var.project_name}-frontend-server"
    Tier = "Frontend"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_instance.backend
  ]
}

# ==================================================
# RDS SUBNET GROUP
# ==================================================

resource "aws_db_subnet_group" "main" {
  name = "ecommerce-db-subnet-group"

  subnet_ids = [
    aws_subnet.this["db_1a"].id,
    aws_subnet.this["db_1b"].id
  ]

  tags = {
    Name = "${var.project_name}-DB-subnet-group"
  }
}

# ==================================================
# PRIVATE RDS MYSQL DATABASE
# ==================================================

resource "aws_db_instance" "main" {
  identifier = "ecommerce-mysql-db"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 30
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]

  publicly_accessible        = false
  multi_az                   = false
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-MySQL"
    Tier = "Database"
  }
}

# ==================================================
# PUBLIC APPLICATION LOAD BALANCER
# ==================================================

resource "aws_lb" "main" {
  name               = "ecommerce-public-alb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.this["public_1a"].id,
    aws_subnet.this["public_1b"].id
  ]

  security_groups = [aws_security_group.alb.id]

  tags = {
    Name = "${var.project_name}-ALB"
  }
}

# ==================================================
# FRONTEND TARGET GROUP
# ==================================================

resource "aws_lb_target_group" "frontend" {
  name     = "ecommerce-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.project_name}-frontend-TG"
  }
}

resource "aws_lb_target_group_attachment" "frontend" {
  target_group_arn = aws_lb_target_group.frontend.arn
  target_id        = aws_instance.frontend.id
  port             = 80
}

# ==================================================
# HTTP LISTENER
# ==================================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
