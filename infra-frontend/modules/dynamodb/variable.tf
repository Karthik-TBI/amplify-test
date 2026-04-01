variable "env" {
  description = "Environment name (e.g., dev, uat, prod)"
  type        = string
}

# variable "tags" {
#   description = "Common tags for all resources"
#   type        = map(string)
#   default = {
#     "map-migrated" = "migSZUDBD3OY2"
#     "track"        = "portal"
#     "env"          = "dev"
#     "project"      = "pw"
#   }
# }

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
}