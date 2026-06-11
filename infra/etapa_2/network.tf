# === #
# VPC #
# === #

resource "aws_vpc" "innovatech_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "innovatech-vpc" }
}

# ================ #
# INTERNET GATEWAY #
# ================ #

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.innovatech_vpc.id

  tags = { Name = "innovatech-igw" }
}

# === #
# NAT #
# === #

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = { Name = "innovatech-nat-eip-${count.index}" }
}

# ======= #
# SUBNETS #
# ======= #

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.innovatech_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 1) 
  availability_zone = var.azs[count.index]
  
  map_public_ip_on_launch = true 

  tags = {
    Name                     = "innovatech-public-subnet-${var.azs[count.index]}"
    "kubernetes.io/role/elb" = "1" 
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.innovatech_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 1) 
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "innovatech-private-subnet-${var.azs[count.index]}"
    "kubernetes.io/role/internal-elb" = "1" 
  }
}

# =========== #
# NAT GATEWAY #
# =========== #

resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = { Name = "innovatech-nat-gateway-${count.index}" }
}

# ========================== #
# ROUTE TABLES & ASSOCIATION #
# ========================== #

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.innovatech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "innovatech-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.innovatech_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = { Name = "innovatech-private-rt-${count.index}" }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}