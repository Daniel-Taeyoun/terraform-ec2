variable "service_name" {
  type        = string
  description = "Service Name"
  default     = null
}

variable "cidr_block" {
  type        = string
  description = "VPN CIDR value"
  default     = null
}

variable "environment_upper" {
  type = string
  default = null
}

variable "environment_lower" {
  type = string
  default = null
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = []
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = []
}

variable "azs" {
  type        = list(string)
  description = "Availability Zone"
  default     = []
}

variable "aws_region" {
  type = string
  default = null
}