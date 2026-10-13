output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.name.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.name.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.name.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.name.public_dns
}

output "instance_name" {
  description = "Name of the EC2 instance"
  value       = aws_instance.name.tags["Name"]
}
