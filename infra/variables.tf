variable "rest_api_id" {
  description = "ID of the existing API Gateway REST API"
  type        = string
}

variable "parent_resource_id" {
  description = "Parent resource ID, usually the root '/' resource"
  type        = string
}

variable "hello_resource_id" {
  description = "If /hello path already exists, provide its resource ID to prevent conflict"
  type        = string
  default     = ""
}

variable "vpc_link_id" {
  description = "ID of the VPC Link to connect API Gateway with internal NLB"
  type        = string
}

variable "nlb_name" {
  description = "Name of the internal Network Load Balancer to connect via VPC Link"
  type        = string
}
variable "region" {
  description = "AWS region to deploy to"
  type        = string
}
