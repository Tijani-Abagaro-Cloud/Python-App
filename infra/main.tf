data "aws_lb" "nlb" {
  name = var.nlb_name
}

locals {
  hello_resource_id      = var.hello_resource_id != "" ? var.hello_resource_id : aws_api_gateway_resource.hello[0].id
  create_hello_resources = var.hello_resource_id == ""
}

# Conditionally create hello resource if not supplied
resource "aws_api_gateway_resource" "hello" {
  count       = local.create_hello_resources ? 1 : 0
  rest_api_id = var.rest_api_id
  parent_id   = var.parent_resource_id
  path_part   = "hello"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [path_part]
  }
}

resource "aws_api_gateway_method" "hello_get" {
  count         = local.create_hello_resources ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = local.hello_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = data.aws_lb.nlb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fargate_tg.arn
  }
}


resource "aws_api_gateway_integration" "hello_integration" {
  count                   = local.create_hello_resources ? 1 : 0
  rest_api_id             = var.rest_api_id
  resource_id             = local.hello_resource_id
  http_method             = aws_api_gateway_method.hello_get[0].http_method
  integration_http_method = "GET"
  type                    = "HTTP"
  uri                     = aws_lb_listener.http.arn  # ✅ Listener ARN used here
  connection_type         = "VPC_LINK"
  connection_id           = var.vpc_link_id
  timeout_milliseconds    = 29000
}


resource "aws_api_gateway_method_response" "hello_response" {
  count         = local.create_hello_resources ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = local.hello_resource_id
  http_method   = aws_api_gateway_method.hello_get[0].http_method
  status_code   = "200"
}

resource "aws_api_gateway_integration_response" "hello_integration_response" {
  count         = local.create_hello_resources ? 1 : 0
  rest_api_id   = var.rest_api_id
  resource_id   = local.hello_resource_id
  http_method   = aws_api_gateway_method.hello_get[0].http_method
  status_code   = "200"
  response_templates = {
    "application/json" = null
    "text/plain"       = null
  }
}


resource "aws_api_gateway_deployment" "api_deploy" {
  rest_api_id = var.rest_api_id

  depends_on = [
    aws_api_gateway_method.hello_get,
    aws_api_gateway_integration.hello_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}


