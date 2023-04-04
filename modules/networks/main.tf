locals {
  owner                     = "khoamd"
  suffixed                  = "terraform"
  region                    = "us-east-1"
  availability_zone_server  = "a"
  availability_zone_master  = "b"
  availability_zone_dev     = "c"
  availability_zone_prod    = "d"
  cidr_block_vpc            = "10.123.0.0/16"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  cidr_block_subnet_server  = "10.123.1.0/24"
  cidr_block_subnet_master  = "10.123.10.0/24"
  cidr_block_subnet_dev     = "10.123.20.0/24"
  cidr_block_subnet_prod    = "10.123.30.0/24"
  cidr_block_route_table    = "0.0.0.0/0"
  sg_ingress_port           = "0"
  sg_ingress_protocol       = "-1"
  sg_egress_port            = "0"
  sg_egress_protocol        = "-1"
  cidr_block_security_group = ["0.0.0.0/0"]

  tags = {
    "Owner" = local.owner
  }
}

resource "aws_vpc" "khoamd_vpc" {
  cidr_block           = local.cidr_block_vpc
  enable_dns_hostnames = local.enable_dns_hostnames
  enable_dns_support   = local.enable_dns_support

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-vpc-${local.suffixed}"
  }
}

resource "aws_subnet" "khoamd_subnet_server" {
  vpc_id            = aws_vpc.khoamd_vpc.id
  cidr_block        = local.cidr_block_subnet_server
  availability_zone = "${local.region}${local.availability_zone_server}"

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-subnet-server-${local.suffixed}"
  }
}

resource "aws_subnet" "khoamd_subnet_master" {
  vpc_id            = aws_vpc.khoamd_vpc.id
  cidr_block        = local.cidr_block_subnet_master
  availability_zone = "${local.region}${local.availability_zone_master}"

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-subnet-master-${local.suffixed}"
  }
}

resource "aws_subnet" "khoamd_subnet_dev" {
  vpc_id            = aws_vpc.khoamd_vpc.id
  cidr_block        = local.cidr_block_subnet_dev
  availability_zone = "${local.region}${local.availability_zone_dev}"

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-subnet-dev-${local.suffixed}"
  }
}

resource "aws_subnet" "khoamd_subnet_prod" {
  vpc_id            = aws_vpc.khoamd_vpc.id
  cidr_block        = local.cidr_block_subnet_prod
  availability_zone = "${local.region}${local.availability_zone_prod}"

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-subnet-prod-${local.suffixed}"
  }
}

resource "aws_internet_gateway" "khoamd_igw" {
  vpc_id = aws_vpc.khoamd_vpc.id

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-igw-${local.suffixed}"
  }
}

resource "aws_route_table" "khoamd_rtb" {
  vpc_id = aws_vpc.khoamd_vpc.id

  route {
    cidr_block = local.cidr_block_route_table
    gateway_id = aws_internet_gateway.khoamd_igw.id
  }

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-rtb-${local.suffixed}"
  }
}

# This abstract resource has been created simultaneously with aws_route_table.khoamd_rtb
# resource "aws_route" "khoamd_route" {
#     route_table_id = aws_route_table.khoamd_rtb.id
#     destination_cidr_block = local.cidr_block_route_table
#     gateway_id = aws_internet_gateway.khoamd_igw.id 
# }

resource "aws_route_table_association" "khoamd_rtb_server_association" {
  route_table_id = aws_route_table.khoamd_rtb.id
  subnet_id      = aws_subnet.khoamd_subnet_server.id
}

resource "aws_route_table_association" "khoamd_rtb_master_association" {
  route_table_id = aws_route_table.khoamd_rtb.id
  subnet_id      = aws_subnet.khoamd_subnet_master.id
}

resource "aws_route_table_association" "khoamd_rtb_dev_association" {
  route_table_id = aws_route_table.khoamd_rtb.id
  subnet_id      = aws_subnet.khoamd_subnet_dev.id
}

resource "aws_route_table_association" "khoamd_rtb_prod_association" {
  route_table_id = aws_route_table.khoamd_rtb.id
  subnet_id      = aws_subnet.khoamd_subnet_prod.id
}

resource "aws_security_group" "khoamd_sg" {
  name        = "${local.owner}-sg-${local.suffixed}"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.khoamd_vpc.id

  ingress {
    from_port   = local.sg_ingress_port
    to_port     = local.sg_ingress_port
    protocol    = local.sg_ingress_protocol
    cidr_blocks = local.cidr_block_security_group
  }

  egress {
    from_port   = local.sg_egress_port
    to_port     = local.sg_egress_port
    protocol    = local.sg_egress_protocol
    cidr_blocks = local.cidr_block_security_group
  }

  tags = {
    "Owner" = local.owner
    "Name"  = "${local.owner}-sg-${local.suffixed}"
  }
}

output "khoamd_subnet_server_id" {
  description = "khoamd subnet server ID"
  value       = try(aws_subnet.khoamd_subnet_server.id, "")
}

output "khoamd_subnet_master_id" {
  description = "khoamd subnet master ID"
  value       = try(aws_subnet.khoamd_subnet_master.id, "")
}

output "khoamd_subnet_dev_id" {
  description = "khoamd subnet dev ID"
  value       = try(aws_subnet.khoamd_subnet_dev.id, "")
}

output "khoamd_subnet_prod_id" {
  description = "khoamd subnet prod ID"
  value       = try(aws_subnet.khoamd_subnet_prod.id, "")
}

output "khoamd_sg_id" {
  description = "khoamd security group ID"
  value       = try([aws_security_group.khoamd_sg.id], "")
}
