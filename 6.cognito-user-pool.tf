resource "aws_cognito_user_pool" "user_pool" {
  name = "my_user_pool"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                    = "cognito_authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_cognito_user_pool.user_pool.id
  identity_source        = "method.request.header.Authorization"
  provider_arns = [
    aws_cognito_user_pool.user_pool.arn,
  ]
  type = "COGNITO_USER_POOLS"
}

