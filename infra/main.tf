provider "aws" {
  region = "us-east-2"
}

# -----------------------
# Variables (or inline if preferred)
# -----------------------
variable "nlb_arn" {
  default = "arn:aws:elasticloadbalancing:us-east-2:861079279572:loadbalancer/net/if-enterprise-nlb-dev/b923e2d9b88803ac"
}

variable "nlb_dns" {
  default = "if-enterprise-nlb-dev-b923e2d9b88803ac.elb.us-east-2.amazonaws.com"
}

# -----------------------
# 1. Create REST API Gateway
# -----------------------
resource "aws_api_gateway_rest_api" "rest_api" {
  name = "lf-enterprise-api-gw-dev"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# -----------------------
# 2. Create VPC Link to Internal NLB
# -----------------------
resource "aws_api_gateway_vpc_link" "vpc_link" {
  name        = "lf-enterprise-api-dev-vpclink"
  target_arns = [var.nlb_arn]
}

# -----------------------
# 3. Create /hello resource under root "/"
# -----------------------
resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "hello"
}

# -----------------------
# 4. Create GET method on /hello
# -----------------------
resource "aws_api_gateway_method" "hello_get" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "GET"
  authorization = "NONE"
}

# -----------------------
# 5. Integrate GET /hello with NLB via VPC Link
# -----------------------
resource "aws_api_gateway_integration" "hello_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = "http://${var.nlb_dns}/hello"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.vpc_link.id
}

# -----------------------
# 6. Define Method Response
# -----------------------
resource "aws_api_gateway_method_response" "hello_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = "200"
}

# -----------------------
# 7. Define Integration Response
# -----------------------
resource "aws_api_gateway_integration_response" "hello_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.hello.id
  http_method = aws_api_gateway_method.hello_get.http_method
  status_code = aws_api_gateway_method_response.hello_response.status_code
}

# -----------------------
# 8. Deploy API
# -----------------------
resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [aws_api_gateway_integration.hello_integration]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  description = "Initial deployment"
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.api_deploy.id
}
