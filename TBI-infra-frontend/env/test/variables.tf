variable "region" { type = string }
variable "tags" { type = map(string) }



# Routes reference lambdas by lambda_key; we resolve the actual ARN in locals
variable "routes" {
  type = list(object({
    method                 = string
    path                   = string
    lambda_key             = string
    auth                   = bool
    timeout_ms             = number
    payload_format_version = string
  }))
}

variable "api_name" { type = string }

variable "cors" {
  type = object({
    allow_origins     = list(string)
    allow_headers     = list(string)
    allow_methods     = list(string)
    expose_headers    = list(string)
    allow_credentials = bool
    max_age           = number
  })
}

variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool to look up"
  type        = string
}

variable "authorizer" {
  type = object({
    name            = string
    identity_source = string
    # issuer          = string
    # audience        = list(string)
  })
}

variable "stages" {
  type = object({
    create_default      = bool
    default_auto_deploy = bool
    create_dev          = bool
    dev_auto_deploy     = bool
  })
}


# One execution role per Lambda (you choose the keys: external, cases, etc.)
variable "iam_roles" {
  type = map(object({
    role_name           = string
    managed_policy_arns = list(string)
  }))
}

# One Lambda per key; role_key must match a key in iam_roles
variable "lambdas" {
  type = map(object({
    role_key           = string
    function_name      = string
    description        = string
    runtime            = string
    handler            = string
    memory_size        = number
    timeout            = number
    architectures      = list(string)
    package_filename   = string
    env_vars           = map(string)
    log_retention_days = number
    enable_xray        = bool
  }))
}

# Map of DynamoDB tables keyed by an id you choose
variable "dynamodb_tables" {
  type = map(object({
    name         = string
    billing_mode = string
    hash_key = object({
      name = string
      type = string
    })
    range_key = optional(object({
      name = string
      type = string
    }))
    global_secondary_indexes = optional(list(object({
      name = string
      hash_key = object({
        name = string
        type = string
      })
      range_key = optional(object({
        name = string
        type = string
      }))
      projection_type    = string
      non_key_attributes = optional(list(string))
    })))
    pitr_enabled = bool
    ttl = optional(object({
      enabled        = bool
      attribute_name = optional(string)
    }))
    stream_enabled   = bool
    stream_view_type = optional(string)
  }))
}