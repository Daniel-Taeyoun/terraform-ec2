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

variable "cidr_block" {
  type        = map(string)
  description = "VPN CIDR value"
  default     = {
    "develop" : "10.12.0.0/16"
  }
}

variable "public_subnet_cidr" {
  type        = map(list(string))
  description = "Public Subnet CIDR values"
  default     = {
    "develop" : ["10.12.0.0/24", "10.12.8.0/24"]
  }
}

variable "private_subnet_cidr" {
  type        = map(list(string))
  description = "Private Subnet CIDR values"
  default     = {
    "develop" : ["10.12.24.0/24", "10.12.32.0/24"]
  }
}

variable "azs" {
  type        = map(list(string))
  description = "Availability Zone"
  default     = {
    "develop" : ["ap-northeast-2a", "ap-northeast-2c"]
  }
}

provider "aws" {
  region = var.aws_region[terraform.workspace]
  profile = "default"
}

#######################################################
# Network Infra(ex. VPC, Subnet, Internet Gateway ...)
#######################################################
module "aws_network" {
  source = "../modules/network"
  aws_region = var.aws_region[terraform.workspace]
  service_name = "tch-devops"

  cidr_block = var.cidr_block[terraform.workspace]
  public_subnet_cidr = var.public_subnet_cidr[terraform.workspace]
  private_subnet_cidr = var.private_subnet_cidr[terraform.workspace]
  azs = var.azs[terraform.workspace]

  environment_upper = upper(var.environment[terraform.workspace])
  environment_lower = lower(var.environment[terraform.workspace])
}

terraform {
  backend "s3" {
    bucket = "tch-devops-terraform-state"
    key = "1-Network/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}