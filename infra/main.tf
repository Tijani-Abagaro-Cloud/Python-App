provider "aws" {
  region = "us-east-2"
}

# Lookup NLB dynamically
data "aws_lb" "nlb" {
  name = var.nlb_name
}

# Create REST API Gateway
resource "aws_api_gateway_rest_api" "rest_api" {
  name = "lf-enterprise-api-gw-dev"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create VPC Link
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "lf-enterprise-api-dev-vpclink"
  target_arns = [data.aws_lb.nlb.arn]
}

# Create /hello resource
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "hello"
}

# Create GET method
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with NLB via VPC Link
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${data.aws_lb.nlb.dns_name}/hello"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id

  depends_on = [
    aws_api_gateway_vpc_link.vpc_link
  ]
}

# Method response
resource "aws_api_gateway_method_response" "hello_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

# Integration response ( key fix: add depends_on!)
resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_response.status_code

  depends_on = [
    aws_api_gateway_integration.hello_integration
  ]
}

# Deploy the API 
resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  depends_on = [
    aws_api_gateway_integration_response.hello_integration_response
  ]
}

# Create stage
resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}
