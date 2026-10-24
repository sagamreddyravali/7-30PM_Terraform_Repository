
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "remote_demo" {
  ami                         = "ami-0d6e34c14757a048b"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-050aab28c968aae07"
  vpc_security_group_ids      = ["sg-0e0499c34eff979a5"]
  key_name                    = "terraform-remote-exec-key"
  associate_public_ip_address = true

  tags = {
    Name = "Terraform-Remote-Exec-Practice"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/terraform-remote-exec-key-new.pem")
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y nginx",
      "sudo systemctl enable --now nginx",
      "sudo systemctl status nginx --no-pager"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/welcome.txt"
    destination = "/home/ec2-user/welcome.txt"
  }
}

resource "local_file" "example" {
  filename = "${path.module}/hello.txt"
  content  = "Hello from Terraform"

  provisioner "local-exec" {
    command = "echo Provisioner is working"
  }
}

resource "terraform_data" "copy_welcome_file" {
  triggers_replace = [
    filesha256("${path.module}/welcome.txt"),
    aws_instance.remote_demo.id
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("${path.module}/terraform-remote-exec-key-new.pem")
    host        = aws_instance.remote_demo.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/welcome.txt"
    destination = "/home/ec2-user/welcome.txt"
  }
}
