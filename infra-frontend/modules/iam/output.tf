# output "appsync-dynamo-access-role-arn" {
#   value = aws_iam_role.appsync-dynamo-access-role.arn
# } 

output "devicefarm-s3-access-role-arn" {
  value = aws_iam_role.devicefarm-s3-access-role.arn
}

output "cognito-sign-up-trigger-role-arn" {
  value = aws_iam_role.cognito-sign-up-trigger-role.arn
}

output "cognito-sign-in-trigger-role-arn" {
  value = aws_iam_role.cognito-sign-in-trigger-role.arn
}

output "sign-in-trigger-update-role-arn" {
  value = aws_iam_role.sign-in-trigger-update-role.arn
}

output "jobstatus-change-ws-role-arn" {
  value = aws_iam_role.jobstatus-change-ws-role.arn
}