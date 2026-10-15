resource "aws_instance" "name" {
    ami = "ami-0d27e0fb3bac4d7245"
    instance_type = "t2.micro"
    availability_zone = "us-east-1b"
    tags = {
        Name = "nit"
    }
}

resource "aws_s3_bucket" "name" {
    bucket = "wertyudfghj"
  
}

#terraform plan -target=aws_s3_bucket.name #we can apply specifc respource by using targets