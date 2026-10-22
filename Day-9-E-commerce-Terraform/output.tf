
output "vpc_id" {
  description = "E-commerce VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_ids" {
  description = "All eight subnet IDs"
  value = {
    for name, subnet in aws_subnet.this :
    name => subnet.id
  }
}

output "frontend_instance_id" {
  value = aws_instance.frontend.id
}

output "frontend_private_ip" {
  value = aws_instance.frontend.private_ip
}

output "backend_instance_id" {
  value = aws_instance.backend.id
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}

output "ssm_iam_role" {
  value = aws_iam_role.ec2_ssm_role.name
}

output "database_endpoint" {
  description = "Private RDS endpoint"
  value       = aws_db_instance.main.address
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "load_balancer_dns" {
  description = "Public HTTP application URL"
  value       = "http://${aws_lb.main.dns_name}"
}
