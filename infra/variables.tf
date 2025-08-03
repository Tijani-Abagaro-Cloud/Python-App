variable "region" {}
variable "rest_api_id" {}
variable "parent_resource_id" {}
variable "hello_resource_id" {
  default = ""
}
variable "vpc_link_id" {}
variable "nlb_name" {}
variable "web_acl_arn" {
  default = null
}
