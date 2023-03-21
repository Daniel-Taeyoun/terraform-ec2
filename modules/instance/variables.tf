variable "vpc_id" {
  type = string
  description = "VPC ID"
  default = null
}

variable "subnet_id" {
  type = list(string)
  description = "Subnet ID"
  default = []
}

variable "ami_id" {
  type = string
  description = "Amazon Machine Image ID"
  default = "ami-0e38c97339cddf4bd"
  validation {
    condition     = length(var.ami_id) > 4 && substr(var.ami_id, 0, 4) == "ami-"
    error_message = "The ami_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "instance_type" {
  type = string
  description = "AWS Instance Type"
  default = "t2.micro"
}

variable "service_name" {
  type = string
  description = "Service Name"
  default = null
}

variable "security_group_prefix_name" {
  type = string
  description = "Security Group Prefix Name"
  default = null
}