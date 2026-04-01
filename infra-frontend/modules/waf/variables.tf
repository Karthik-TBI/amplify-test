variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "cognito-arn" {
  description = "Cognito user pool arn"
  type = string
}

# variable "appsync-graphql-arn" {
#   description = "Appsync graphql api arn"
#   type = string
# }