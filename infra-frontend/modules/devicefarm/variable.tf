variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "assume_role_arn" {
  description = "Role assumed to deploy in specific account."
  type        = string
}