variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "nlb_name" {
  description = "Name of the internal NLB"
  type        = string
}

variable "rest_api_id" {
  description = "ID of the existing REST API Gateway"
  type        = string
}

variable "parent_resource_id" {
  description = "ID of the parent resource (usually root /)"
  type        = string
}
