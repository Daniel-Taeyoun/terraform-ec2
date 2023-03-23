variable "tfvars_environment" {
  type = map(string)
}

variable "tfvars_aws_region" {
  type = map(string)
}

variable "tfvars_service_name" {
  type = string
}

locals {
  subnets_public_a = "sbn-${lower(var.tfvars_environment[terraform.workspace])}-an2-${var.tfvars_service_name}-public-a"
  subnets_public_c = "sbn-${lower(var.tfvars_environment[terraform.workspace])}-an2-${var.tfvars_service_name}-public-c"
}

data "aws_vpc" "tch_devops_vpc" {
  tags = {
    Name = "vpc-${lower(var.tfvars_environment[terraform.workspace])}-${var.tfvars_service_name}"
  }
}

## TODO : subnet ID를 filter?를 통해 List 형태로 호출하는 방법 필요
data "aws_subnet" "tch_devops_subnets_public_a" {
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  filter {
    name   = "tag:Name"
    values = [local.subnets_public_a]
  }
}

data "aws_subnet" "tch_devops_subnets_public_c" {
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  filter {
    name   = "tag:Name"
    values = [local.subnets_public_c]
  }
}

# TODO - 인스턴스 생성 시(instance/main.tf) tag Name 하드 코딩 수정 필요.
#      - 해당 디렉토리 선작업 후 하드코딩(1,2)제거 필요
data "aws_instance" "tch_devops_instances_1" {
  filter {
    name   = "tag:Name"
    values = ["ec2-${var.tfvars_service_name}-1"]
  }
}

data "aws_instance" "tch_devops_instances_2" {
  filter {
    name   = "tag:Name"
    values = ["ec2-${var.tfvars_service_name}-2"]
  }
}

data "aws_security_group" "tch_devops_security_group" {
  filter {
    name   = "tag:Name"
    values = ["scg-ec2-${var.tfvars_service_name}"]
  }
}

provider "aws" {
  region = var.tfvars_aws_region[terraform.workspace]
  profile = "default"
}

#################################################################################
# Elastic Load-Balancer
# (ex. Load-Balancer, Target-Group, Attach ELB & TargetGroup, Config ELB Listener)
#################################################################################
module "aws_elb" {
  source = "../modules/elb"

  service_name = var.tfvars_service_name
  elb_subnet_ids = [data.aws_subnet.tch_devops_subnets_public_a.id, data.aws_subnet.tch_devops_subnets_public_c.id]
  elb_security_groups = [data.aws_security_group.tch_devops_security_group.id]
  vpc_id = data.aws_vpc.tch_devops_vpc.id
  target_group_instance_ids = [data.aws_instance.tch_devops_instances_1.id, data.aws_instance.tch_devops_instances_2.id]
}

terraform {
  backend "s3" {
    bucket = "tch-devops-terraform-state"
    key = "3-ELB/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}