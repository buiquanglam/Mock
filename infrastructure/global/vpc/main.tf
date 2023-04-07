variable "environment" {
  
}

variable "vpc" {
  type = object({
    default_az = string
    cidr_block = string
    azs = list(string)
    public_cidrs = list(string)
    private_cidrs =  list(string)
  })
}

resource "aws_vpc" "global_vpc" {
    cidr_block = var.vpc.cidr_block
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
        "Name" = "Ducdv20-mock-vpc"
        Environment = var.environment
    }
  
}

resource "aws_security_group" "sg_global" {
    name = "sg_global"
    description = "global security group"
    vpc_id = aws_vpc.global_vpc.id
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Terraform - HTTPS x Traffic"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        "Name" = "sg_global"
        Environment = var.environment
    }
}

resource "aws_subnet" "subnet_global_public" {
    count = length(var.vpc.public_cidrs)
    vpc_id = aws_vpc.global_vpc.id
    cidr_block = element(var.vpc.public_cidrs, count.index)
    availability_zone = element(var.vpc.azs, count.index)
    # map_customer_owned_ip_on_launch = true
    

    tags = {
        Name = "${var.environment}_public_subnet_${format("%03d", count.index+1)}"
        Environment                               = var.environment
        "kubernetes.io/cluster/ducdv20_global_eks" = "shared"
        "kubernetes.io/role/elb"                  = "1"

    }
  
}

resource "aws_subnet" "subnet_global_private" {
    count = length(var.vpc.private_cidrs)
    
    vpc_id = aws_vpc.global_vpc.id
    cidr_block = element(var.vpc.private_cidrs, count.index)
    availability_zone = element(var.vpc.azs, count.index)

    tags = {
        Name = "${var.environment}_private_subnet_${format("%03d", count.index+1)}"
        Environment = var.environment
        "kubernetes.io/cluster/ducdv20_global_eks" = "shared"
        "kubernetes.io/role/internal-elb"         = "1"

    }
}

resource "aws_internet_gateway" "global_igw" {
    vpc_id = aws_vpc.global_vpc.id
    
    tags = {
        Name = "igw_${var.environment}"
        Environment = var.environment
    }
  
}

resource "aws_eip" "global_eip" {
    vpc = true
  
}

resource "aws_nat_gateway" "global_nat" {
    allocation_id = aws_eip.global_eip.id
    subnet_id = aws_subnet.subnet_global_public[0].id

    depends_on = [
      aws_internet_gateway.global_igw,
      aws_eip.global_eip,
    ]

    tags = {
        Name = "NAT_${var.environment}"
        Environment = var.environment
    }
  
}

resource "aws_route_table" "global_public_rtb" {
    vpc_id = aws_vpc.global_vpc.id

    tags = {
      "Name" = "rtb_${var.environment}_public_rtb"
      Environment = var.environment
    }
}

resource "aws_route" "rtb_route_global_public" {
    route_table_id = aws_route_table.global_public_rtb.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global_igw.id
  
}

resource "aws_route_table_association" "rtb_association_global_public" {
    count = length(var.vpc.azs)
    subnet_id = element(aws_subnet.subnet_global_public.*.id, count.index)
    route_table_id = aws_route_table.global_public_rtb.id
  
}

resource "aws_route_table" "global_private_rtb" {
    vpc_id = aws_vpc.global_vpc.id

    tags = {
      "Name" = "rtb_${var.environment}_private_rtb"
      Environment = var.environment
    }
}

resource "aws_route" "rtb_route_global_private" {
    route_table_id = aws_route_table.global_private_rtb.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.global_nat.id
  
}

resource "aws_route_table_association" "rtb_association_global_private" {
    count = length(var.vpc.azs)
    subnet_id = element(aws_subnet.subnet_global_private.*.id, count.index)
    route_table_id = aws_route_table.global_private_rtb.id
}

resource "aws_vpc_endpoint" "vpc_global_s3_endpoint" {
    vpc_id = aws_vpc.global_vpc.id
    service_name = "com.amazonaws.ap-southeast-1.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = [aws_route_table.global_public_rtb.id,aws_route_table.global_private_rtb.id]
  
}


output "vpc_id" {
  value = aws_vpc.global_vpc.id
}

output "vpc_sg_id" {
  value = aws_security_group.sg_global.id
}

output "vpc_rt_id" {
  value = aws_route_table.global_public_rtb.id
}

output "vpc_nat_public_ip" {
  value = aws_nat_gateway.global_nat.public_ip
}

output "vpc_subnet_public_ids" {
  value = aws_subnet.subnet_global_public.*.id
}

output "vpc_subnet_private_ids" {
  value = aws_subnet.subnet_global_private.*.id
}
