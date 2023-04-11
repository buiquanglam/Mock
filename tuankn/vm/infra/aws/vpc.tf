#define local variable
locals {
  timestamp            = formatdate("YYYYMMDD-hhmmss", timestamp())
  target_azs           = data.aws_availability_zones.available.names
  common_tags          = { "CommonTags" : "${var.project}-${var.env}-${local.timestamp}" }
  private_keyname_path = "${path.cwd}/keys"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "mock-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge({
    Name = "mock-vpc"
  }, local.common_tags)
}

resource "aws_internet_gateway" "mock-vpc" {
  vpc_id = aws_vpc.mock-vpc.id
  tags = merge({
    Name = "igw-mock-vpc"
    }, local.common_tags
  )
}

resource "aws_nat_gateway" "mock-vpc" {
  allocation_id = aws_eip.nat-gw.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [aws_subnet.public]
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.mock-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mock-vpc.id
  }
  tags = merge(
    {
      Name = "public-rt"
    }, local.common_tags
  )
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.mock-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mock-vpc.id
  }
  tags = merge(
    {
      Name = "private-rt"
    }, local.common_tags
  )
}

resource "aws_subnet" "public" {
  count = var.number_public_subnets

  vpc_id                  = aws_vpc.mock-vpc.id
  cidr_block              = lookup(var.public_subnets_cidr, count.index)
  availability_zone       = local.target_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name = "public-subnet-${format("%02d", count.index + 1)}"
    },
  local.common_tags)
}

resource "aws_subnet" "private" {
  count = var.number_private_subnets

  vpc_id                  = aws_vpc.mock-vpc.id
  cidr_block              = lookup(var.private_subnets_cidr, count.index)
  availability_zone       = local.target_azs[count.index]
  map_public_ip_on_launch = true

  tags = merge({
    Name = "private-subnet-${format("%02d", count.index + 1)}"
    },
  local.common_tags)
}

resource "aws_route_table_association" "public" {
  count          = var.number_public_subnets
  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.number_private_subnets
  route_table_id = aws_route_table.private-rt.id
  subnet_id      = aws_subnet.private[count.index].id
}
