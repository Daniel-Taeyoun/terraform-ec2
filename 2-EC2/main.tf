variable "aws_region" {
  type = map(string)
  default = {
    "develop" : "ap-northeast-2"
    "stage" : "ap-northeast-2"
    "main" : "ap-northeast-1"
  }
}
variable "vpc_id" {
  default = "vpc-0835e68a89fedca6a"
}

variable "subnet_id" {
  type = list(string)
  default = ["subnet-04877697587e94e41", "subnet-0b9bfefbadbe30063"]
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
}