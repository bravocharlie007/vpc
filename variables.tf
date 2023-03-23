variable "custom_vpc" {
  description = "VPC for testing environment"
  type        = string
  default     = "15.0.0.0/16"
}

variable "instance_tenancy" {
  description = "it defines the tenancy of VPC. Whether it's default or dedicated"
  type        = string
  default     = "default"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "parameter_base_path_prefix" {
  type = string
  default = "/application/ec2deployer/"
  sensitive = true
}

variable "parameter_base_path_suffix" {
  type = string
  default = "/resource/terraform/"
}

#variable "AWS_ACCESS_KEY_ID" {}
#
#variable "AWS_SECRET_ACCESS_KEY" {}