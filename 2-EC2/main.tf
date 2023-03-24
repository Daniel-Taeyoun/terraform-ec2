locals {
  subnets_private_a = "sbn-dev-an2-tch-devops-private-a"
  subnets_private_c = "sbn-dev-an2-tch-devops-private-c"
}

variable "tfvars_aws_region" {
  type = map(string)
}

variable "tfvars_environment" {
  type = map(string)
}

variable "tfvars_service_name" {
  type = string
}

# data를 통해서 Cloud 내에 있는 리소스 ID 값을 받아올 수 있다.
data "aws_vpc" "tch_devops_vpc" {
  tags = {
    Name = "vpc-${lower(var.tfvars_environment[terraform.workspace])}-${var.tfvars_service_name}"
  }
}

## TODO : subnet ID를 filter?를 통해 List 형태로 호출하는 방법 필요
data "aws_subnet" "tch_devops_subnets_private_a" {
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  filter {
    name   = "tag:Name"
    values = [local.subnets_private_a]
  }
}

data "aws_subnet" "tch_devops_subnets_private_c" {
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  filter {
    name   = "tag:Name"
    values = [local.subnets_private_c]
  }
}

provider "aws" {
  region = var.tfvars_aws_region[terraform.workspace]
  profile = "default"
}

#######################################################
# Instance Setting(ex. EC2, Security Group)
#######################################################
module "aws_instance" {
  source = "../modules/instance"
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  subnet_id = [data.aws_subnet.tch_devops_subnets_private_a.id, data.aws_subnet.tch_devops_subnets_private_c.id]
  service_name = var.tfvars_service_name
}

terraform {
  backend "s3" {
    bucket = "tch-devops-terraform-state"
    key = "2-EC2/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}