###############################################################
# infra/security_groups.tf
###############################################################

# ----- Bouncer #1: Jumpbox -----
resource "aws_security_group" "jumpbox" {
  name        = "jumpbox-sg-${terraform.workspace}"
  description = "Allow SSH from internet to jumpbox"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tighten this to YOUR_IP/32 for safety
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "jumpbox-sg-${terraform.workspace}" }
}

# ----- Bouncer #2: Webserver -----
resource "aws_security_group" "webserver" {
  name        = "webserver-sg-${terraform.workspace}"
  description = "Allow SSH only from jumpbox"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from jumpbox only"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jumpbox.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "webserver-sg-${terraform.workspace}" }
}

