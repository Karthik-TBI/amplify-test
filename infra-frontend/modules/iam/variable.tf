variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

# variable "dynamo-table-arn" {
#   description = "ARN for dynamodb table"
#   type        = string
# }

variable "s3-bucket-arn" {
  description = "s3 bucket arn"
  type        = string
}

# variable "account_id" {
#   description = "AWS Account ID"
#   type        = string
# }

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# Required variables
variable "cognito-user-pool-id" {
  description = "The ID of the Cognito User Pool"
  type        = string
}

variable "netsuite_secret_arn" {
  description = "ARN of the NetSuite credentials secret"
  type        = string
}
variable "s3_kms_key_arn" {
  description = "NetSuite Realm"
  type        = string
  default     = "placeholder"
}

variable "dynamodb_cmk_arn" {
  description = "The ARN of the KMS CMK used for DynamoDB encryption"
  type        = string
}

variable "scheduler_dispatcher_secret_arn" {
  description = "The ARN of the scheduler-dispatcher-secret-arn"
  type        = string
}