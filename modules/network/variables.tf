variable "cidr_block" {
  type        = map(string)
  description = "VPN CIDR value"
  default     = {
    "develop" : "10.12.0.0/16"
  }
}

variable "environment_upper" {
  type = map(string)
  default = {
    "develop" : "DEV"
  }
}

variable "environment_lower" {
  type = map(string)
  default = {
    "develop" : "dev"
  }
}

variable "public_subnet_cidrs" {
  type        = map(list(string))
  description = "Public Subnet CIDR values"
  default     = {
    "develop" : ["10.12.0.0/24", "10.12.8.0/24"]
  }
}

variable "private_subnet_cidrs" {
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

variable "demo_devops_region" {
  type = map(string)
  default = {
    "develop" : "ap-northeast-2"
  }
}

