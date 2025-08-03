variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_link_id" {
  type = string
}

variable "rest_api_id" {
  type = string
}

variable "parent_resource_id" {
  type = string
}

variable "nlb_name" {
  type    = string
  default = "if-enterprise-nlb-dev"
}
