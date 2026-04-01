variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
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


variable "s3_kms_key_arn" {
  description = "NetSuite Realm"
  type        = string
  default     = "placeholder"
}

variable "lambda_websocket_user" {
  description = "scheduler dispatcher"
  type        = string
  default     = "placeholder"
}

variable "lambda_websocket_pwd" {
  description = "scheduler dispatcher"
  type        = string
  default     = "placeholder"
}

variable "lambda_websocket_domain_api_url" {
  description = "scheduler dispatcher"
  type        = string
  default     = "placeholder"
}