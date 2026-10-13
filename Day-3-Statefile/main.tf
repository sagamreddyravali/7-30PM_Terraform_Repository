resource "aws_instance" "name" {
  ami               = var.ami_id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone

  tags = {
    Name = var.instance_name
  }
}
