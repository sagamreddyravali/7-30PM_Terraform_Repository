terraform {
  backend "s3" {
    bucket         = "44333111ravalibucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # dynamodb_table = "terraform-state-locks" # recommended for state locking
  }
}