provider "aws" {
  region = var.region
}

# Lookup existing internal NLB
data "aws_lb" "nlb" {
  name = var.nlb_name
}

# Create the VPC Link
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "lf-enterprise-api-dev-vpclink"
  target_arns = [data.aws_lb.nlb.arn]
}

# Create /hello resource
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "hello"
}

# Add GET method on /hello
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integrate /hello with internal NLB via VPC Link
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.nlb.dns_name}/hello"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
  timeout_milliseconds    = 29000
}

# Method response for GET /hello
resource "aws_api_gateway_method_response" "hello_response" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

# Integration response for GET /hello
resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id = var.rest_api_id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"

  response_templates = {
    "application/json" = null
    "text/plain"       = null
  }
}

# Deploy the updated API
resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = var.rest_api_id

  depends_on = [
    aws_api_gateway_integration.hello_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}
