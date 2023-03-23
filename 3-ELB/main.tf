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

resource "aws_lb" "alb-tch-devops-nginx" {
  name               = "alb-${var.tfvars_service_name}-nginx"
  internal           = false
  load_balancer_type = "application"

  # Public 서브넷 설정
  subnets = [data.aws_subnet.tch_devops_subnets_public_a.id, data.aws_subnet.tch_devops_subnets_public_c.id]

  # EC2에서 생성된 Security Group으로 설정한다
  security_groups = [data.aws_security_group.tch_devops_security_group.id]
}

resource "aws_lb_target_group" "tg-daniel-nginx" {
  name     = "tg-${var.tfvars_service_name}-nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.tch_devops_vpc.id
}

resource "aws_lb_target_group_attachment" "attach-target-group" {
  count = length([data.aws_instance.tch_devops_instances_1.id, data.aws_instance.tch_devops_instances_2.id])
  target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
  target_id        = [data.aws_instance.tch_devops_instances_1.id, data.aws_instance.tch_devops_instances_2.id][count.index]
  port             = 80
}

resource "aws_lb_listener" "attach-alb-listener" {
  load_balancer_arn = aws_lb.alb-tch-devops-nginx.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg-daniel-nginx.arn
    type = "forward"
  }
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