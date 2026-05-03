###############################################################
# infra/outputs.tf
###############################################################

output "workspace" {
  description = "Which workspace this state belongs to"
  value       = terraform.workspace
}

output "jumpbox_public_ip" {
  description = "Public IP of the jumpbox - SSH to this from your laptop"
  value       = aws_instance.jumpbox.public_ip
}

output "webserver_private_ip" {
  description = "Private IP of the webserver - SSH from the jumpbox"
  value       = aws_instance.webserver.private_ip
}

output "s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

