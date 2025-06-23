# filepath: /Users/vaibhav_patel/Documents/EcoMonitor/Terraform/Networking.tf
# AWS VPC Configuration for EcoMonitor Project

# Create VPC
resource "aws_vpc" "ecomonitor_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "EcoMonitor-VPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ecomonitor_vpc.id
  
  tags = {
    Name = "EcoMonitor-IGW"
  }
}

# Create Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.ecomonitor_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${data.aws_region.current.name}a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "EcoMonitor-Public-Subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.ecomonitor_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${data.aws_region.current.name}b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "EcoMonitor-Public-Subnet-2"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.ecomonitor_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${data.aws_region.current.name}a"
  
  tags = {
    Name = "EcoMonitor-Private-Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.ecomonitor_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${data.aws_region.current.name}b"
  
  tags = {
    Name = "EcoMonitor-Private-Subnet-2"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  
  tags = {
    Name = "EcoMonitor-NAT-EIP"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  
  tags = {
    Name = "EcoMonitor-NAT-Gateway"
  }

  depends_on = [aws_internet_gateway.igw]
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ecomonitor_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "EcoMonitor-Public-RT"
  }
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.ecomonitor_vpc.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  
  tags = {
    Name = "EcoMonitor-Private-RT"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

# Output VPC and Subnet IDs
output "vpc_id" {
  value       = aws_vpc.ecomonitor_vpc.id
  description = "ID of the EcoMonitor VPC"
}

output "public_subnet_ids" {
  value       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  description = "IDs of public subnets"
}

output "private_subnet_ids" {
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  description = "IDs of private subnets"
}