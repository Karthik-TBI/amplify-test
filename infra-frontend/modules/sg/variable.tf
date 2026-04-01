# variables.tf
# variable "vpc_id" {
#   description = "VPC ID where the Lambda security group will be created"
#   type        = string
# }

variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to the security group"
  type        = map(string)
  default     = {}
}