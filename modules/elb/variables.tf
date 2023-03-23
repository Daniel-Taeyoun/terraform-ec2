variable "service_name" {
  type = string
  default = null
}

variable "elb_security_groups" {
  type = list(string)
  default = []
}

variable "elb_subnet_ids" {
  type = list(string)
  default = []
}

variable "vpc_id" {
  type = string
  default = null
}

variable "target_group_instance_ids" {
  type = list(string)
  default = []
}