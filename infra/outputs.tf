output "api_invoke_url" {
  description = "Invoke URL for testing the /hello endpoint"
  value       = "${aws_api_gateway_stage.dev.invoke_url}/hello"
}
