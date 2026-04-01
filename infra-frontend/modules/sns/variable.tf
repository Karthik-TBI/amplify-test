variable "env" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}

