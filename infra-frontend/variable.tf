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
variable "assume_role_arn" {
  description = "Role assumed to deploy in specific account."
  type        = string
}

variable "consumer_key" {
  description = "NetSuite Consumer Key"
  type        = string
  default     = "placeholder"  # Will be updated in AWS Console
}

variable "consumer_secret" {
  description = "NetSuite Consumer Secret"
  type        = string
  default     = "placeholder"
}

variable "token" {
  description = "NetSuite Token"
  type        = string
  default     = "placeholder"
}

variable "token_secret" {
  description = "NetSuite Token Secret"
  type        = string
  default     = "placeholder"
}

variable "realm" {
  description = "NetSuite Realm"
  type        = string
  default     = "placeholder"
}