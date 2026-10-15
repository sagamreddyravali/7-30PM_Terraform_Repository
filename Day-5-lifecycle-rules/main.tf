resource "aws_instance" "name" {
    ami = "ami-097855b862d5b1eb2"
    instance_type = "t2.micro"
    availability_zone = "us-east-1b"
    tags = {
        Name = "ravali-1"
    }

  
#   lifecycle {
#     ignore_changes = [tags]
#   }
lifecycle {
  create_before_destroy = true
}

# lifecycle {
#    prevent_destroy = true
# }
}