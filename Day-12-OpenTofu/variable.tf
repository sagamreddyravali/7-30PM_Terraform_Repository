
variable "aws_region" {
  description = "AWS region for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_name" {
  description = "Name tag for EC2"
  type        = string
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID; leave empty to look it up"
  type        = string
  default     = ""
}
