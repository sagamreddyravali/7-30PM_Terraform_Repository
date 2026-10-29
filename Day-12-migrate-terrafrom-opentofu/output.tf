
output "instance_id" {
  value = aws_instance.migration_demo.id
}

output "instance_public_ip" {
  value = aws_instance.migration_demo.public_ip
}

output "instance_state" {
  value = aws_instance.migration_demo.instance_state
}
