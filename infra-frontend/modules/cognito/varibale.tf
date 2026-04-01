variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "pre-sign-up-lambda-arn" {
  description = "Pre sign up lambda arn"
  type = string
}

variable "pre-sign-in-lambda-arn" {
  description = "Pre sign in lambda arn"
  type = string
}
