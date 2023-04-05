terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "~>3.0"
      }
    }
}

# Configure the AWS provider 
provider "aws" {
    region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "minhpt17-mock-vpc"{
    cidr_block = var.cidr_block[0]
    tags = {
        Name = "minhpt17-mock-vpc"
    }
}

# Create Subnet (Public)
resource "aws_subnet" "minhpt17-mock-subnet1" {
    vpc_id = aws_vpc.minhpt17-mock-vpc.id
    cidr_block = var.cidr_block[1]
    tags = {
        Name = "minhpt17-mock-subnet1"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "minhpt17-mock-igw" {
    vpc_id = aws_vpc.minhpt17-mock-vpc.id
    tags = {
        Name = "minhpt17-mock-igw"
    }
}

# Create Security Group
resource "aws_security_group" "minhpt17-mock-sg" {
    name = "minhpt17-mock-sg"
    description = "To allow inbound and outbount traffic"
    vpc_id = aws_vpc.minhpt17-mock-vpc.id
    dynamic ingress {
        iterator = port
        for_each = var.ports
            content {
              from_port = port.value
              to_port = port.value
              protocol = "tcp"
              cidr_blocks = ["0.0.0.0/0"]
            }
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "allow traffic"
    }
}

# Create route table and association
resource "aws_route_table" "minhpt17-mock-rtb" {
    vpc_id = aws_vpc.minhpt17-mock-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.minhpt17-mock-igw.id
    }
    tags = {
        Name = "minhpt17-mock-rtb"
    }
}

resource "aws_route_table_association" "minhpt17-mock-rtba" {
    subnet_id = aws_subnet.minhpt17-mock-subnet1.id
    route_table_id = aws_route_table.minhpt17-mock-rtb.id
}

# Create an AWS EC2 Instance to host Jenkins
resource "aws_instance" "Jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "minhpt18"
  vpc_security_group_ids = [aws_security_group.minhpt17-mock-sg.id]
  subnet_id = aws_subnet.minhpt17-mock-subnet1.id
  associate_public_ip_address = true
  user_data = file("./userdata/InstallJenkins.sh")

  tags = {
    Name = "minhpt17-jenkins-server"
  }
}

# Create an AWS EC2 Instance to host Ansible Controller
resource "aws_instance" "Ansible-Controller" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "minhpt18"
  vpc_security_group_ids = [aws_security_group.minhpt17-mock-sg.id]
  subnet_id = aws_subnet.minhpt17-mock-subnet1.id
  associate_public_ip_address = true
  user_data = file("./userdata/InstallAnsibleController.sh")

  tags = {
    Name = "minhpt17-ansible-controller"
  }
}

#Create an AWS EC2 Instance to host Sonatype Nexus
resource "aws_instance" "Nexus" {
  ami           = var.ami
  instance_type = var.instance_type_for_nexus
  key_name = "minhpt18"
  vpc_security_group_ids = [aws_security_group.minhpt17-mock-sg.id]
  subnet_id = aws_subnet.minhpt17-mock-subnet1.id
  associate_public_ip_address = true
  user_data = file("./userdata/InstallNexus.sh")

  tags = {
    Name = "minhpt17-nexus-server"
  }
}

#Create an AWS EC2 Instance to host Docker
resource "aws_instance" "DockerHost" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name = "minhpt18"
  vpc_security_group_ids = [aws_security_group.minhpt17-mock-sg.id]
  subnet_id = aws_subnet.minhpt17-mock-subnet1.id
  associate_public_ip_address = true
  user_data = file("./userdata/InstallDocker.sh")

  tags = {
    Name = "minhpt17-dockerhost"
  }
}