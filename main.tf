provider "aws" {
    region = "eu-north-1"
    access_key = var.access_key
    secret_key = var.secret_key
}

variable "subnet-cidr_block" {}
variable "vpc-cidr_block" {}
variable "_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}

variable "access_key" {
    description= "access key"
}
variable "secret_key" {
    description= "secret key"


}
resource "aws_vpc" "dev-vpc" {
    cidr_block = var.vpc-cidr_block
    tags = {
      Name: " ${var.env_prefix}-vpc"
    }
    
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.subnet-cidr_block
    availability_zone = var._zone
    tags = {
      Name: "${var.env_prefix}-subnet-1"
    }
}
resource "aws_route_table" "myapp-route-table" {
    vpc_id = aws_vpc.dev-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-gw.id
    }
    tags = {
        Name: " ${var.env_prefix}-rtb"
    }
}
resource "aws_internet_gateway" "myapp-gw" {
    vpc_id = aws_vpc.dev-vpc.id
    tags = {
        Name: " ${var.env_prefix}-igw"
    }
}
resource "aws_route_table_association" "a-rtb" {
    subnet_id = aws_subnet.dev-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id

}
resource "aws_security_group" "myapp-sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My Security Group"
  }
}
# Terraform example for Amazon Linux 2 in eu-north-1
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.amazon_linux_2.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.dev-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var._zone
    associate_public_ip_address = true
    key_name = "server-key-pair"

    tags = {
        Name: " ${var.env_prefix}-server"
    }
  
}
