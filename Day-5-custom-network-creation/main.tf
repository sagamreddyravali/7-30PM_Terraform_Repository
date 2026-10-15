
resource "aws_vpc" "ravali_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Ravali_VPC"
  }
}

# Public Subnet
resource "aws_subnet" "ravali_publicsubnet" {
  vpc_id                  = aws_vpc.ravali_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Ravali_Public_Subnet"
  }
}

# Private Subnet
resource "aws_subnet" "ravali_privatesubnet" {
  vpc_id            = aws_vpc.ravali_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Ravali_Private_Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ravali_igw" {
  vpc_id = aws_vpc.ravali_vpc.id

  tags = {
    Name = "Ravali_IGW"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "ravali_nat_eip" {
  domain = "vpc"

  tags = {
    Name = "Ravali_NAT_EIP"
  }
}

# NAT Gateway (must be in the public subnet)
resource "aws_nat_gateway" "ravali_natgw" {
  allocation_id = aws_eip.ravali_nat_eip.id
  subnet_id     = aws_subnet.ravali_publicsubnet.id

  tags = {
    Name = "Ravali_NAT_Gateway"
  }

  depends_on = [aws_internet_gateway.ravali_igw]
}

# Public Route Table
resource "aws_route_table" "ravali_public_rt" {
  vpc_id = aws_vpc.ravali_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ravali_igw.id
  }

  tags = {
    Name = "Ravali_Public_Route_Table"
  }
}

# Private Route Table
resource "aws_route_table" "ravali_private_rt" {
  vpc_id = aws_vpc.ravali_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ravali_natgw.id
  }

  tags = {
    Name = "Ravali_Private_Route_Table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "ravali_public_rta" {
  subnet_id      = aws_subnet.ravali_publicsubnet.id
  route_table_id = aws_route_table.ravali_public_rt.id
}

# Private Route Table Association
resource "aws_route_table_association" "ravali_private_rta" {
  subnet_id      = aws_subnet.ravali_privatesubnet.id
  route_table_id = aws_route_table.ravali_private_rt.id
}

# Security Group
resource "aws_security_group" "ravali_sg" {
  name        = "Ravali_SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.ravali_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Ravali_SG"
  }
}

# Public EC2 Instance
resource "aws_instance" "ravali_instance" {
  ami                         = "ami-097855b862d5b1eb2"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.ravali_publicsubnet.id
  vpc_security_group_ids      = [aws_security_group.ravali_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "Ravali_public_Instance"
  }
}

# Private EC2 Instance
resource "aws_instance" "ravali_private_instance" {
  ami                    = "ami-097855b862d5b1eb2"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.ravali_privatesubnet.id
  vpc_security_group_ids = [aws_security_group.ravali_sg.id]

  tags = {
    Name = "Ravali_private_Instance"
  }
}
