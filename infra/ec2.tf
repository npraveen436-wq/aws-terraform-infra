###############################################################
# infra/ec2.tf
###############################################################

# ----- Auto-fetch the latest Amazon Linux 2023 AMI -----
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ----- Jumpbox (public subnet) -----
resource "aws_instance" "jumpbox" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.jumpbox.id]
  key_name               = "gitnew" # your existing keypair

  tags = { Name = "jumpbox-${terraform.workspace}" }
}

# ----- Webserver (private subnet) -----
resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name               = "gitnew" # your existing keypair

  tags = { Name = "webserver-${terraform.workspace}" }
}

