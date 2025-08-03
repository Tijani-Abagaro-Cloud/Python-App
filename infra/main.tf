provider "aws" {
  region = "us-east-2"
}

# Lookup NLB by name
data "aws_lb" "nlb" {
  name = var.nlb_name
}

# Create REST API Gateway
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = var.api_name
  description = "Public REST API with VPC Link to private NLB"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Create VPC Link to internal NLB
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = var.vpc_link_name
  target_arns = [data.aws_lb.nlb.arn]
}

# Create /hello resource
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "hello"
}

# Create GET method for /hello
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# Integration with internal NLB via VPC Link
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${data.aws_lb.nlb.dns_name}/hello"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id

  depends_on = [aws_api_gateway_vpc_link.vpc_link]
}


# Method response for GET /hello
resource "aws_api_gateway_method_response" "hello_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

# Integration response
resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_response.status_code

  depends_on = [aws_api_gateway_integration.hello_integration]
}

# Deploy API
resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeploy = timestamp()
  }

  depends_on = [
    aws_api_gateway_integration_response.hello_integration_response
  ]
}

# Stage for dev
resource "aws_api_gateway_stage" "dev" {
  stage_name    = var.stage
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}

output "api_gateway_invoke_url" {
  description = "Invoke URL for /hello endpoint"
  value       = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.${var.region}.amazonaws.com/${var.stage}/hello"
}
