output "pre-sign-up-lambda-arn" {
  value = aws_lambda_function.cognito-sign-up-trigger.arn
}

output "pre-sign-in-lambda-arn" {
  value = aws_lambda_function.cognito-sign-in-trigger.arn
}



