# In your secrets module (modules/secrets/outputs.tf)
output "netsuite_secret_arn" {
  value = aws_secretsmanager_secret.netsuite_credentials.arn
}

output "scheduler_dispatcher_secret_arn" {
  value = aws_secretsmanager_secret.scheduler_credentials.arn
}