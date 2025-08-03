# Dynamically look up the internal NLB DNS name
data "aws_lb" "nlb" {
  name = var.nlb_name
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = var.rest_api_id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = var.rest_api_id
  resource_id             = aws_api_gateway_resource.hello.id
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
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id         = var.rest_api_id
  resource_id         = aws_api_gateway_resource.hello.id
  http_method         = aws_api_gateway_method.hello_get.http_method
  status_code         = aws_api_gateway_method_response.hello_response.status_code
  selection_pattern   = ""
}

resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = var.rest_api_id
  depends_on  = [aws_api_gateway_integration.hello_integration]
}

resource "aws_api_gateway_stage" "dev" {
  rest_api_id   = var.rest_api_id
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}
