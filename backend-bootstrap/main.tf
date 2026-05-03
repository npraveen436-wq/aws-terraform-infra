###############################################################
# backend-bootstrap/main.tf
#
# RUN THIS FOLDER ONCE, EVER.
#
# This creates the S3 bucket + DynamoDB table that will store
# the Terraform state file for your *real* project (in ../infra).
#
# The state of THIS bootstrap project lives locally on your
# laptop (in backend-bootstrap/terraform.tfstate). That's fine
# because you almost never touch this folder again.
###############################################################

provider "aws" {
  region = "us-east-1"
}

# -------- S3 bucket where state files will live --------
resource "aws_s3_bucket" "tfstate" {
  bucket = "my-tfstate-pnethu-2026"   # <-- CHANGE to a globally unique name

  # Safety net: prevent accidental deletion.
  # If you want to destroy this later, set this to false first.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "terraform-state"
    Purpose = "Stores Terraform state files"
  }
}

# -------- Versioning: keep history of every state change --------
# If state ever gets corrupted, you can restore an older version.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -------- Encrypt state files at rest --------
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------- Block ALL public access to the state bucket --------
# State files often contain secrets (IPs, ARNs, sometimes passwords).
# This must NEVER be public.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------- DynamoDB table for state locking --------
# When someone runs `terraform apply`, Terraform writes a lock
# entry here. If a second person tries to apply at the same
# time, they'll see "state is locked" and have to wait.
# Prevents two people from corrupting state simultaneously.
resource "aws_dynamodb_table" "tflock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"   # ~free for this use case
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name    = "terraform-state-lock"
    Purpose = "Locks Terraform state to prevent concurrent edits"
  }
}

# -------- Useful info printed after apply --------
output "tfstate_bucket_name" {
  description = "Use this in your infra/backend.tf"
  value       = aws_s3_bucket.tfstate.id
}

output "tflock_table_name" {
  description = "Use this in your infra/backend.tf"
  value       = aws_dynamodb_table.tflock.name
}

