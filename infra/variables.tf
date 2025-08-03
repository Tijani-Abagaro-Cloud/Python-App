# Updated Terraform (CI/CD Safe) – API Gateway + Internal NLB (VPC Link)
# This version avoids conflicts by using conditional creation and handles existing resources gracefully

# ----------------------------------------
# versions.tf
# ----------------------------------------
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ----------------------------------------
# variables.tf
# ----------------------------------------
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

variable "hello_resource_id" {
  type        = string
  description = "Pre-existing /hello resource ID if already created"
  default     = ""
}

# ----------------------------------------
# terraform.tfvars
# ----------------------------------------
# Example:
# region             = "us-east-2"
# vpc_link_id        = "dun05z"
# rest_api_id        = "zvi27nd948"
# parent_resource_id = "9zss9qf83h"
# nlb_name           = "if-enterprise-nlb-dev"
# hello_resource_id  = "iywo1t"

# ----------------------------------------
# main.tf
# ----------------------------------------

data "aws_lb" "nlb" {
  name = var.nlb_name
}

# Use existing /hello resource if provided
resource "aws_api_gateway_resource" "hello" {
  count       = var.hello_resource_id == "" ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "hello"
}

locals {
  hello_resource_id = var.hello_resource_id != "" ? var.hello_resource_id : aws_api_gateway_resource.hello[0].id
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = var.rest_api_id
  resource_id   = local.hello_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = local.hello_resource_id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.nlb.dns_name}/hello"
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_method_response" "hello_response" {
  rest_api_id = var.rest_api_id
  resource_id = local.hello_resource_id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id         = var.rest_api_id
  resource_id         = local.hello_resource_id
  http_method         = aws_api_gateway_method.hello_get.http_method
  status_code         = aws_api_gateway_method_response.hello_response.status_code
  selection_pattern   = ""
  response_templates = {
    "application/json" = ""
    "text/plain"       = ""
  }
}

resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_integration.hello_integration]
}

resource "aws_api_gateway_stage" "dev" {
  lifecycle {
    create_before_destroy = true
    ignore_changes = [deployment_id]  # Avoid churn on every apply
  }

  rest_api_id   = var.rest_api_id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}
