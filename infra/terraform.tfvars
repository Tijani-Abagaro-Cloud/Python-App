# Required settings for API Gateway + VPC Link + Internal NLB routing

region              = "us-east-2"

# Name of your existing internal NLB
nlb_name            = "if-enterprise-nlb-dev"

# Existing API Gateway settings (use `aws apigateway get-resources` to look up)
rest_api_id         = "zvi27nd948"
parent_resource_id  = "9zss9qf83h"   # This is typically the root resource ("/")

# Existing VPC Link created for internal NLB
vpc_link_id         = "dun05z"

# (Optional) Existing /hello resource ID
# Leave this empty ("") if you want Terraform to create /hello
hello_resource_id   = "r4camp"  # Or "" if Terraform should create it
