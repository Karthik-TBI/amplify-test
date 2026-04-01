output "cognito-user-pool-id" {
  value = aws_cognito_user_pool.user-pool.id
}

output "cognito-user-pool-arn" {
  value = aws_cognito_user_pool.user-pool.arn
}

output "cognito-user-pool-client-id" {
  value = aws_cognito_user_pool_client.user-pool-client.id
}