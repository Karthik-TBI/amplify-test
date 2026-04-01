variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "cognito-user-pool-id" {
  description = "Cognito user pool id"
  type        = string
}

variable "cognito-user-pool-client-id" {
  description = "Cognito user pool id"
  type        = string
}