
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "my_ec2" {
  ami = (
    var.ami_id != ""
    ? var.ami_id
    : data.aws_ssm_parameter.amazon_linux_2023.value
  )

  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = "dev"
    ManagedBy   = "OpenTofu"
  }
}
#after prepare all files run the following commands to deploy the EC2 instance
#Configure AWS credentials using aws configure command
#Initialize OpenTofu using the command: opentofu init
#Validate your code using the command: opentofu validate
#Review the execution plan using the command: opentofu plan
#Create the EC2 instance using the command: opentofu apply
#View the outputs using the command: opentofu output
#Delete the EC2 instance when finished using    the command: opentofu destroy
#to check opentofu installed or not using this command: opentofu version or winget list --id OpenTofu.Tofu