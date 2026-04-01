output "dynamo-table-arn" {
  value = aws_dynamodb_table.appsync-db-table.arn
}

output "dynamo-table-name" {
  value = aws_dynamodb_table.appsync-db-table.name
}

# Outputs for Routes table
output "routes-table-arn" {
  value = aws_dynamodb_table.routes-db-table.arn
}

output "routes-table-name" {
  value = aws_dynamodb_table.routes-db-table.name
}

# Outputs for jobs
output "jobs-table-arn" {
  value = aws_dynamodb_table.routes-db-table.arn
}

output "jobs-table-name" {
  value = aws_dynamodb_table.routes-db-table.name
}

# Outputs for job details
output "job_details-table-arn" {
  value = aws_dynamodb_table.routes-db-table.arn
}

output "job_details-table-name" {
  value = aws_dynamodb_table.routes-db-table.name
}

output "jobs-table-stream-arn" {
  value = aws_dynamodb_table.jobs-db-table.stream_arn
}

# Outputs for vehicle details
output "vehicle_inspections-table-arn" {
  value = aws_dynamodb_table.vehicle_inspections-db-table.arn
}

output "vehicle_inspections-table-name" {
  value = aws_dynamodb_table.vehicle_inspections-db-table.name
}

output "dynamodb_cmk_arn" {
  description = "The ARN of the KMS CMK used for DynamoDB encryption"
  value       = aws_kms_key.dynamodb_cmk.arn
}

output "dynamodb_cmk_alias_arn" {
  description = "The ARN of the KMS CMK alias used for DynamoDB encryption"
  value       = aws_kms_alias.dynamodb_cmk_alias.arn
}