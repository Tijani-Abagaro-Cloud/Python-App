locals {
  # Determine whether to use an existing /hello resource or create a new one
  use_existing_hello_id  = var.hello_resource_id != ""

  # Final resource ID to use everywhere downstream
  hello_resource_id = local.use_existing_hello_id ? var.hello_resource_id : aws_api_gateway_resource.hello[0].id

  # Flag to conditionally create method, integration, etc.
  create_hello_resources = !local.use_existing_hello_id
}
