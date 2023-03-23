variable "tfvars_aws_region" {
  type = map(string)
}

variable "tfvars_aws_profile" {
  type = string
}

variable "tfvars_service_name" {
  type = string
}

locals {
  bucketName = "${var.tfvars_service_name}-terraform-state"
  ssl_algorithm = "AES256"
  dynamoDbName = "terraform-up-and-running-locks"
}

provider "aws" {
  region = var.tfvars_aws_region[terraform.workspace]
  profile = var.tfvars_aws_profile
}

resource "aws_s3_bucket" "terraform_bucket_state" {
  bucket = local.bucketName

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = local.bucketName
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_bucket_encrypt" {
  bucket = local.bucketName
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = local.ssl_algorithm
    }
  }
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = local.dynamoDbName
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "tch-devops-terraform-state"
    key = "global/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "terraform-up-and-running-locks"
    encrypt = true
  }
}

