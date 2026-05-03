###############################################################
# infra/s3.tf
# Bucket name includes the workspace, so each workspace
# (dev, staging, prod) gets its own bucket automatically.
###############################################################

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-app-bucket-${terraform.workspace}-pnethu-2026"   # CHANGE this

  tags = { Name = "my-bucket-${terraform.workspace}" }
}

