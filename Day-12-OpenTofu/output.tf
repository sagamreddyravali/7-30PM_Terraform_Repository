
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_ec2.id
}

output "instance_type" {
  description = "Type of the EC2 instance"
  value       = aws_instance.my_ec2.instance_type
}

output "public_ip" {
  description = "Public IP address, if assigned"
  value       = aws_instance.my_ec2.public_ip
}

output "public_dns" {
  description = "Public DNS name, if assigned"
  value       = aws_instance.my_ec2.public_dns
}

output "instance_state" {
  description = "Current EC2 instance state"
  value       = aws_instance.my_ec2.instance_state
}
