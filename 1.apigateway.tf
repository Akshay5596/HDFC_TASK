
# Define the API Gateway Rest API
resource "aws_api_gateway_rest_api" "api" {
  name        = "dummyDataAPI"
  description = "API for generating dummy data"
}

# Define the /data resource
resource "aws_api_gateway_resource" "data" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "data"
}

# Define the GET method for /data
resource "aws_api_gateway_method" "get_data" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# Define a Deployment resource (required for stages)
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_method.get_data]
}

# Define Usage Plan for rate limiting
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  name = "dummyDataAPIUsagePlan"

  throttle_settings {
    rate_limit = 10    # Requests per second
    burst_limit = 20   # Maximum burst capacity
  }
}

# Associate Usage Plan with API Stage
resource "aws_api_gateway_usage_plan_key" "api_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}

# Define API Key for clients
resource "aws_api_gateway_api_key" "api_key" {
  name        = "dummyDataAPIKey"
  description = "API key for rate limiting access to the dummy data API"
  enabled     = true
}
