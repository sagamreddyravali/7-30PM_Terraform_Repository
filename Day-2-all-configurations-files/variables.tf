
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "ravali_vpc"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "ravali_subnet"
}

variable "availability_zone" {
  description = "Availability Zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "map_public_ip_on_launch" {
  description = "Enable automatic public IP assignment"
  type        = bool
  default     = true
}

