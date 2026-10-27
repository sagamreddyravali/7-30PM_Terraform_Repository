
resource "aws_security_group" "ravali-project-devops" {
  name        = "ravali-project-devops"
  description = "Multiple ingress rules with different CIDR sources"

  ingress = [
    # SSH - allow only admin IP
    {
      description      = "SSH from admin IP"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["203.0.113.10/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    # HTTP - allow everyone
    {
      description      = "HTTP from anywhere"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    # HTTPS - allow everyone
    {
      description      = "HTTPS from anywhere"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    # Jenkins - allow private network
    {
      description      = "Jenkins from private network"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["10.0.0.0/16"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    # MySQL - allow database subnet
    {
      description      = "MySQL from database subnet"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = ["10.0.3.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },

    # Backend application - allow application subnet
    {
      description      = "Backend from application subnet"
      from_port        = 5000
      to_port          = 5000
      protocol         = "tcp"
      cidr_blocks      = ["10.0.4.0/24"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ravali-project-devops"
  }
}
