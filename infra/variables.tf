variable "region" {
  type    = string
  default = "us-east-2"
}

variable "vpc_link_id" {
  type        = string
  description = "ID of the existing API Gateway VPC Link"
}

variable "rest_api_id" {
  type        = string
  description = "ID of the existing REST API"
}

variable "parent_resource_id" {
  type        = string
  description = "ID of the root or parent resource in the REST API"
}

variable "nlb_name" {
  type        = string
  description = "Name of the internal NLB to look up"
  default     = "if-enterprise-nlb-dev"
}

variable "hello_resource_id" {
  type        = string
  description = "Use this to reference existing /hello resource if already created"
  default     = ""
}
