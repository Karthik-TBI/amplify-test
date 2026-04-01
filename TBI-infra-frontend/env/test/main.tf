

locals {
  routes_with_arns = [
    for _, r in var.routes : merge(r, {
      # For API Gateway integration
      lambda_invoke_arn = module.lambda[r.lambda_key].invoke_arn

      # For aws_lambda_permission.function_name
      lambda_function_arn = module.lambda[r.lambda_key].arn
      # (or alternatively: lambda_function_name = module.lambda[r.lambda_key].name)
    })
  ]
}



module "api" {
  source = "../../modules/apigateway"
  api_name   = var.api_name
  cors       = var.cors
  authorizer = var.authorizer # only name + identity_source
  cognito_user_pool_name = var.cognito_user_pool_name
  routes     = local.routes_with_arns
  stages = var.stages
  tags   = var.tags
}

output "api_id" { value = module.api.api_id }
output "default_invoke" { value = module.api.default_invoke_url }
output "dev_invoke" { value = module.api.dev_invoke_url }
output "lambda_arns" { value = { for k, m in module.lambda : k => m.arn } }



# NOTE: providers.tf and backend.tf already exist in env/test (per your setup)

locals {
  # pass-through
  iam_roles = var.iam_roles
  lambdas   = var.lambdas
}

# Create one execution role per entry
module "iam_roles" {
  source   = "../../modules/iam"
  for_each = local.iam_roles

  role_name           = each.value.role_name
  managed_policy_arns = each.value.managed_policy_arns
  tags                = var.tags
}

# Create one Lambda per entry, using the corresponding role_arn
module "lambda" {
  source   = "../../modules/lambdas"
  for_each = local.lambdas

  role_arn           = module.iam_roles[each.value.role_key].role_arn
  function_name      = each.value.function_name
  description        = each.value.description
  runtime            = each.value.runtime
  handler            = each.value.handler
  memory_size        = each.value.memory_size
  timeout            = each.value.timeout
  architectures      = each.value.architectures
  package_filename   = each.value.package_filename
  env_vars           = each.value.env_vars
  log_retention_days = each.value.log_retention_days
  enable_xray        = each.value.enable_xray
  tags               = var.tags
}


output "lambda_invoke_arns" {
  value = { for k, m in module.lambda : k => m.invoke_arn }
}

output "iam_role_arns" {
  value = { for k, m in module.iam_roles : k => m.role_arn }
}



# Create the three DynamoDB tables from the map
module "ddb_tables" {
  source   = "../../modules/dynamodb"
  for_each = var.dynamodb_tables

  name         = each.value.name
  billing_mode = each.value.billing_mode
  hash_key     = each.value.hash_key
  range_key    = try(each.value.range_key, {})

  global_secondary_indexes = try(each.value.global_secondary_indexes, [])
  pitr_enabled             = each.value.pitr_enabled
  ttl                      = try(each.value.ttl, { enabled = false })
  stream_enabled           = each.value.stream_enabled
  stream_view_type         = try(each.value.stream_view_type, null)

  tags = var.tags
}

# Helpful outputs
output "dynamodb_table_arns" {
  value = { for k, m in module.ddb_tables : k => m.arn }
}

output "dynamodb_table_names" {
  value = { for k, m in module.ddb_tables : k => m.name }
}