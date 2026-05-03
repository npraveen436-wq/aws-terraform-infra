###############################################################
# infra/backend.tf
#
# Tells Terraform: "Don't store the state file on the laptop.
# Store it in this S3 bucket instead, with locking via DynamoDB."
#
# Run `terraform init` after creating this file to migrate state.
#
# IMPORTANT: The bucket and DynamoDB table referenced here must
# already exist (created by ../backend-bootstrap).
###############################################################

terraform {
  backend "s3" {
    bucket         = "my-tfstate-pnethu-2026" # <-- match the bucket from backend-bootstrap
    key            = "projects/aws-jumpbox/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

