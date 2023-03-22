locals {
  service_name      = "tch-devops"
  subnets_private_a = "sbn-dev-an2-tch-devops-private-a"
  subnets_private_c = "sbn-dev-an2-tch-devops-private-c"
}

variable "aws_region" {
  type = map(string)
  default = {
    "develop" : "ap-northeast-2"
    "stage" : "ap-northeast-2"
    "main" : "ap-northeast-1"
  }
}

variable "environment" {
  type = map(string)
  default = {
    "develop" : "dev"
    "stage" : "stg"
    "main" : "prd"
  }
}

## TODO : dev 하드코딩 제거 필요
data "aws_vpc" "tch_devops_vpc" {
  tags = {
    Name = "vpc-dev-${local.service_name}"
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
  region = var.aws_region[terraform.workspace]
  profile = "default"
}

#######################################################
# Instance Setting(ex. EC2, Security Group)
#######################################################
module "aws_instance" {
  source = "../modules/instance"
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  subnet_id = [data.aws_subnet.tch_devops_subnets_private_a.id, data.aws_subnet.tch_devops_subnets_private_c.id]
  service_name = local.service_name
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