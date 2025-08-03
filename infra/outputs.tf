output "hello_resource_id" {
  description = "The ID of the /hello resource (existing or newly created)"
  value       = local.hello_resource_id
}

output "api_gateway_stage_invoke_url" {
  description = "Invoke URL for the deployed API stage"
  value       = aws_api_gateway_stage.dev.invoke_url
}
