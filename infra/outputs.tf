output "api_invoke_url" {
  description = "Invoke URL for testing"
  value       = "https://${aws_api_gateway_rest_api.rest_api.id}.execute-api.us-east-2.amazonaws.com/dev/hello"
}
