variable "demo_devops_region" {
  type = map(string)
  default = {
    "develop" : "ap-northeast-2"
    "stage" : "ap-northeast-2"
    "main" : "ap-northeast-1"
  }
}

provider "aws" {
  region = var.demo_devops_region[terraform.workspace]
  profile = "default"
}

#########################################
# Network Infra(ex. VPC, Subnet, Internet Gateway ...)
#########################################
module "aws_network" {
  source = "../modules/network"
}