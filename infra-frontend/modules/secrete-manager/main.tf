# Create secret in Secrets Manager
resource "aws_secretsmanager_secret" "netsuite_credentials" {
  name = "pw-api-netsuite-${var.env}-credentials-secret"
  kms_key_id             = var.s3_kms_key_arn
  recovery_window_in_days = 30

  tags = merge(var.tags, {
    Name = "pw-api-netsuite-${var.env}-credentials-secret"
  })
  

}

resource "aws_secretsmanager_secret_version" "netsuite_credentials" {
  secret_id = aws_secretsmanager_secret.netsuite_credentials.id
  secret_string = jsonencode({
    consumer_key     = var.consumer_key
    consumer_secret  = var.consumer_secret
    token           = var.token
    token_secret    = var.token_secret
    realm           = var.realm
  })
}



####################################################################################################

resource "aws_secretsmanager_secret" "scheduler_credentials" {
  name = "pw-scheduler-dispatcher-${var.env}-secret"
  kms_key_id             = var.s3_kms_key_arn
  recovery_window_in_days = 30

  tags = merge(var.tags, {
    Name = "pw-scheduler-dispatcher-${var.env}-secret"
  })
  

}

resource "aws_secretsmanager_secret_version" "scheduler_credentials" {
  secret_id = aws_secretsmanager_secret.scheduler_credentials.id
  secret_string = jsonencode({
    lambda_websocket_user = var.lambda_websocket_user,
    lambda_websocket_pwd = var.lambda_websocket_pwd,
    lambda_websocket_domain_api_url = var.lambda_websocket_domain_api_url
  })
}


###################################################################################################
