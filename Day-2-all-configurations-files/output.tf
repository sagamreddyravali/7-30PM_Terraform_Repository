
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.developer_vpc.id
}

output "vpc_name" {
  description = "Name of the created VPC"
  value       = aws_vpc.developer_vpc.tags["Name"]
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.developer_vpc.cidr_block
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.developer_subnet.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = aws_subnet.developer_subnet.tags["Name"]
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.developer_subnet.cidr_block
}

output "availability_zone" {
  description = "Availability Zone of the subnet"
  value       = aws_subnet.developer_subnet.availability_zone
}
