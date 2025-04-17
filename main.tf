provider "aws" {
    region = "eu-north-1"
    access_key = var.access_key
    secret_key = var.secret_key
}

variable "subnet-cidr_block" {
    description= "subnet cider block"
  
}
variable "vpc-cidr_block" {
    description = "vpc cider block"
  
}
variable "_zone" {
  
}

variable "access_key" {
    description= "access key"
}
variable "secret_key" {
    description= "secret key"

  
}
resource "aws_vpc" "dev-vpc" {
    cidr_block = var.vpc-cidr_block
    tags = {
      Name: "deployment"
    }
    
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.subnet-cidr_block
    availability_zone = var._zone
    tags = {
      Name: "subnet-1-deployment"
      vpc_env: "dev"
    }
  
}
data "aws_vpc" "exisitng_vpc" {
    default = true
  
}
resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.exisitng_vpc.id
    cidr_block = "172.31.48.0/20"
    availability_zone = var._zone
    tags = {
      Name: "subnet-2-deployment"
    }
    
  
}