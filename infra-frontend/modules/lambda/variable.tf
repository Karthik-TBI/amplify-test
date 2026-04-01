variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "devicefarm-project-arn" {
  description = "Devicefarm project arn"
  type        = string
}

variable "devicefarm-android-devicepool-arn" {
  description = "Android devicepool arn"
  type        = string
}

variable "devicefarm-ios-devicepool-arn" {
  description = "IOS devicepool arn"
  type        = string
}

variable "devicefarm-s3-access-role-arn" {
  description = "Lambda role to access devicefarm and s3"
  type        = string
}

variable "cognito-sign-up-trigger-role-arn" {
  description = "Lambda role for cognito-sign-up-trigger"
  type        = string
}

variable "cognito-sign-in-trigger-role-arn" {
  description = "Lambda role for cognito-sign-in-trigger"
  type        = string
}

variable "sign-in-trigger-update-role-arn" {
  description = "Lambda role for sign-in-trigger-ipdate lambda"
  type        = string
}

variable "jobstatus-change-ws-role-arn" {
  description = "Lambda role for jobstatus-change-ws-role lambda"
  type        = string
}

variable "cognito-user-pool-id" {
  description = "Cognito user pool id"
  type        = string
}

variable "netsuite_secret_arn" {
  description = "ARN of the NetSuite credentials secret"
  type        = string
}

# modules/lambda/variables.tf
# variable "private_subnet_ids" {
#   description = "List of private subnet IDs for Lambda VPC config"
#   type        = list(string)
# }

variable "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  type        = string
}

variable "jobs-table-arn" {
  description = "jobs-table.arn for Lambda functions"
  type        = string
}


