###############################################################
# infra/vpc.tf
# Builds the network: VPC, subnets, gateways, route tables.
###############################################################

# ----- The VPC itself (your private plot of land) -----
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "my-vpc-${terraform.workspace}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
    Owner       = "pnethu"
  }

}

# ----- Internet Gateway (front gate to the internet) -----
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "my-igw-${terraform.workspace}" }
}

# ----- Public Subnet (front yard, gets public IPs) -----
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = { Name = "public-subnet-${terraform.workspace}" }
}

# ----- Private Subnet (backyard, no public IPs) -----
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = { Name = "private-subnet-${terraform.workspace}" }
}

# ----- Elastic IP for the NAT Gateway -----
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = { Name = "nat-eip-${terraform.workspace}" }
}

# ----- NAT Gateway (one-way intercom for the backyard) -----
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags       = { Name = "my-nat-${terraform.workspace}" }
  depends_on = [aws_internet_gateway.igw]
}

# ----- Public Route Table -----
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt-${terraform.workspace}" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ----- Private Route Table -----
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-rt-${terraform.workspace}" }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

