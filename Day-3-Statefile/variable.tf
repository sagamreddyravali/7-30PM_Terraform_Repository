variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-097855b862d5b1eb2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "availability_zone" {
  description = "Availability zone for EC2"
  type        = string
  default     = "us-east-1b"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "Ravali_Instance"
}
