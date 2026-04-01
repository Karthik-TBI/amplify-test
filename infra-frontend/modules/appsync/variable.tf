variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "region" {
  description = "Region used for deployment of AWS resources"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "dynamo-table-name" {
  description = "Name of dynamodb table"
  type        = string
}

variable "appsync-dynamo-access-role-arn" {
  description = "IAM role ARN to allow appsync to perform operations on dynamodb table"
  type        = string
}

variable "cognito-user-pool-id" {
  description = "ID of cognito user pool"
  type        = string
}