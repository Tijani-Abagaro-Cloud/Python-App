variable "region" {
  default = "us-east-2"
}

variable "nlb_name" {
  description = "Name of existing internal NLB"
  default     = "if-enterprise-nlb-dev"
}

variable "api_name" {
  default = "lf-enterprise-api-gw-dev"
}

variable "vpc_link_name" {
  default = "lf-enterprise-api-dev-vpclink"
}

variable "stage" {
  default = "dev"
}
