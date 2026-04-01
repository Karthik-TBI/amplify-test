##########################################################################################


module "iam" {
  source = "./modules/iam"

  env                           = var.env
  tags                          = var.tags
  # dynamo-table-arn              = module.dynamodb.dynamo-table-arn
  s3-bucket-arn                 = module.s3.s3-mobile-app-arn
  cognito-user-pool-id          = module.cognito.cognito-user-pool-id
  s3_kms_key_arn                = module.s3.s3_kms_key_arn
  netsuite_secret_arn           = module.secrete-manager.netsuite_secret_arn
  dynamodb_cmk_arn              = module.dynamodb.dynamodb_cmk_arn
  scheduler_dispatcher_secret_arn = module.secrete-manager.scheduler_dispatcher_secret_arn

}

#module "dynamodb" {
  #source = "./modules/dynamodb"

  #env                           = var.env
  #tags                          = var.tags
#}

module "dynamodb" {
  source = "./modules/dynamodb"

  env                           = var.env
  tags                          = var.tags

#   env  = var.env
#   tags = {
#     "map-migrated" = "migSZUDBD3OY2"
#     "track"        = "portal"
#     "env"          = var.env
#     "project"      = "pw"
#   }
 }


module "cognito" {
  source = "./modules/cognito"

  env                           = var.env
  tags                          = var.tags
  pre-sign-up-lambda-arn        = module.lambda.pre-sign-up-lambda-arn
  pre-sign-in-lambda-arn        = module.lambda.pre-sign-in-lambda-arn
}

# module "appsync" {
#   source = "./modules/appsync"

#   env                           = var.env
#   region                        = var.region
#   tags                          = var.tags
#   dynamo-table-name             = module.dynamodb.dynamo-table-arn
#   appsync-dynamo-access-role-arn= module.iam.appsync-dynamo-access-role-arn
#   cognito-user-pool-id          = module.cognito.cognito-user-pool-id
# }

module "amplify" {
  source = "./modules/amplify"

  env                           = var.env
  tags                          = var.tags
  cognito-user-pool-id          = module.cognito.cognito-user-pool-id
  cognito-user-pool-client-id   = module.cognito.cognito-user-pool-client-id
}

module "s3" {
  source = "./modules/s3"

  env                           = var.env
  tags                          = var.tags
  topic_arn                     = module.sns.topic_arn
}

module "waf" {
  source = "./modules/waf"

  env                           = var.env
  tags                          = var.tags
  cognito-arn                   = module.cognito.cognito-user-pool-arn
  # appsync-graphql-arn           = module.appsync.appsync-graphql-api-arn
}

module "devicefarm" {
  source = "./modules/devicefarm"

  env                           = var.env
  tags                          = var.tags
  assume_role_arn               = var.assume_role_arn
}

module "lambda" {
  source = "./modules/lambda"

  env                           = var.env
  tags                          = var.tags
  devicefarm-project-arn        = module.devicefarm.devicefarm-project-arn
  devicefarm-android-devicepool-arn = module.devicefarm.devicefarm-android-devicepool-arn
  devicefarm-ios-devicepool-arn = module.devicefarm.devicefarm-ios-devicepool-arn
  devicefarm-s3-access-role-arn = module.iam.devicefarm-s3-access-role-arn
  cognito-sign-up-trigger-role-arn      = module.iam.cognito-sign-up-trigger-role-arn
  cognito-sign-in-trigger-role-arn      = module.iam.cognito-sign-in-trigger-role-arn
  sign-in-trigger-update-role-arn       = module.iam.sign-in-trigger-update-role-arn
  cognito-user-pool-id                  = module.cognito.cognito-user-pool-id
  # private_subnet_ids      = var.private_subnet_ids
  lambda_security_group_id = module.lambda_security_group.lambda_security_group_id
  # netsuite_secret_arn = module.secrets.netsuite_secret_arn
  netsuite_secret_arn                 = module.secrete-manager.netsuite_secret_arn
  jobstatus-change-ws-role-arn   = module.iam.jobstatus-change-ws-role-arn
  jobs-table-arn                = module.dynamodb.jobs-table-stream-arn
  
  
}

module "lambda_security_group" {
  source = "./modules/sg"
  
  # vpc_id = var.vpc_id
  env    = var.env
  tags   = var.tags
}


module "sns" {
  source = "./modules/sns"
  
  # vpc_id = var.vpc_id
  env    = var.env
  tags   = var.tags
}

module "secrete-manager" {
  source = "./modules/secrete-manager"
  
  consumer_key    = var.consumer_key
  consumer_secret = var.consumer_secret
  token          = var.token
  token_secret   = var.token_secret
  realm          = var.realm
  env            = var.env
  tags           = var.tags
  s3_kms_key_arn = module.s3.s3_kms_key_arn
}

