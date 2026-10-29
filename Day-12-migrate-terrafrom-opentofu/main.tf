
data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "migration_demo" {
  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = var.instance_type

  tags = {
    Name      = var.instance_name
    ManagedBy = "Terraform-OpenTofu-Practice"
  }
}
#Create the EC2 instance with Terraform
# terraform init
# terraform validate
# terraform plan
# terraform apply
# When prompted, type yes.

# Verify the instance:
# terraform state list
# terraform output instance_id
# Back up the Terraform state
# Before switching tools, create a backup in the same directory:using below command
# cp terraform.tfstate terraform.tfstate.terraform-backup
# Also save a backup of the configuration files. Do not commit state files or backups to GitHub because state can contain sensitive information.

# The OpenTofu migration guide recommends backing up configuration and state before migrating
# Also save a backup of the configuration files. Do not commit state files or backups to GitHub because state can contain sensitive information.

# The OpenTofu migration guide recommends backing up configuration and state before migrating. 
# OpenTofu

# 4. Migrate to OpenTofu
# You don't need to rewrite any of the five .tf files. OpenTofu uses the same HCL configuration for this basic AWS example.

# Initialize OpenTofu in the same directory, where Terraform created the state:using below command
#tofu init   
#Then inspect the state:using command tofu state list
#excepeted output is aws_instance.migration_demo
#now run tofu validate
#tofu plan
# the ideal result is No changes. Your infrastructure matches the configuration.
#if OpenTofu proposes replacing or creating an instance, stop and investigate rather than applying the plan.
#Confirm OpenTofu manages the existing instance using command: tofu output instance_id
#Compare this with the instance ID you recorded before migration: terraform output instance_id
#Both should identify the same EC2 instance.
#For this exercise, the key learning is that you create the resource with Terraform first, then switch 
#to OpenTofu using the same configuration and state—not by creating another EC2 instance 
#or importing the existing one.