data "aws_vpc" "selected" {
  tags = {
    Name = "pw-vpc-${var.env}"
  }
}

data "aws_subnet" "private_az1" {
  tags = {
    Name = "pw-private-subnet-az1-${var.env}"
  }
}

data "aws_subnet" "private_az2" {
  tags = {
    Name = "pw-private-subnet-az2-${var.env}"
  }
}


data "archive_file" "devicefarm-lambda" {
  type        = "zip"
  source_file = "${path.module}/functions/devicefarm-lambda.py"
  output_path = "${path.module}/functions/devicefarm-lambda.zip"
}


##################################################################################################################

resource "aws_lambda_function" "devicefarm-lambda" {
  filename      = "${path.module}/functions/devicefarm-lambda.zip"
  function_name = "pw-lambda-${var.env}-devicefarm-testing"
  role          = var.devicefarm-s3-access-role-arn
  handler       = "devicefarm-lambda.lambda_handler"
  timeout       = 60
  memory_size   = 512

  source_code_hash = data.archive_file.devicefarm-lambda.output_base64sha256

  runtime = "python3.12"

  environment {
    variables = {
      PROJECT_ARN = var.devicefarm-project-arn,
      ANDROID_DEVICEPOOL_ARN = var.devicefarm-android-devicepool-arn,
      IOS_DEVICEPOOL_ARN = var.devicefarm-ios-devicepool-arn
    }
  }

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }


  tags = var.tags
}

data "archive_file" "cognito-trigger" {
  type        = "zip"
  source_dir = "${path.module}/layers/cognito-trigger"
  output_path = "${path.module}/layers/cognito-trigger-layer.zip"
}

resource "aws_lambda_layer_version" "cognito-trigger" {
  filename   = "${path.module}/layers/cognito-trigger-layer.zip"
  layer_name = "pw-lambda-layer-${var.env}-cognito-trigger"

  compatible_runtimes = ["nodejs20.x"]
}



#####################################################################################################################

data "archive_file" "cognito-sign-up-trigger" {
  type        = "zip"
  source_file = "${path.module}/functions/cognito-sign-up-trigger.mjs"
  output_path = "${path.module}/functions/cognito-sign-up-trigger.zip"
}


# Get the secret values from existing secret
data "aws_secretsmanager_secret" "netsuite" {
  arn = var.netsuite_secret_arn  # This comes from your secrets module
}

data "aws_secretsmanager_secret_version" "netsuite" {
  secret_id = data.aws_secretsmanager_secret.netsuite.id
}

locals {
  secret_values = jsondecode(data.aws_secretsmanager_secret_version.netsuite.secret_string)
}

resource "aws_lambda_function" "cognito-sign-up-trigger" {
  filename      = "${path.module}/functions/cognito-sign-up-trigger.zip"
  function_name = "pw-lambda-${var.env}-cognito-sign-up-trigger"
  role          = var.cognito-sign-up-trigger-role-arn
  handler       = "cognito-sign-up-trigger.handler"
  layers        = [aws_lambda_layer_version.cognito-trigger.arn]
  timeout       = 60

  source_code_hash = data.archive_file.cognito-sign-up-trigger.output_base64sha256

  runtime = "nodejs20.x"

    environment {
    variables = {
      CONSUMER_KEY    = local.secret_values.consumer_key
      CONSUMER_SECRET = local.secret_values.consumer_secret
      TOKEN           = local.secret_values.token
      TOKEN_SECRET    = local.secret_values.token_secret
      REALM           = local.secret_values.realm
    }
  }

  # environment {
  #   variables = {
  #     foo=bar
  #   }
  # }

  # environment {
  #   variables = {
  #     NETSUITE_SECRETS_ARN = aws_secretsmanager_secret.netsuite_credentials.arn
        # NETSUITE_SECRETS_ARN = var.NETSUITE_SECRETS_ARN
  #   }
  # }

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }


  tags = var.tags
}



#######################################################################################################################

data "archive_file" "cognito-sign-in-trigger" {
  type        = "zip"
  source_file = "${path.module}/functions/cognito-sign-in-trigger.mjs"
  output_path = "${path.module}/functions/cognito-sign-in-trigger.zip"
}

resource "aws_lambda_function" "cognito-sign-in-trigger" {
  filename      = "${path.module}/functions/cognito-sign-in-trigger.zip"
  function_name = "pw-lambda-${var.env}-cognito-sign-in-trigger"
  role          = var.cognito-sign-in-trigger-role-arn
  handler       = "cognito-sign-in-trigger.handler"
  layers        = [aws_lambda_layer_version.cognito-trigger.arn]
  timeout       = 60

  source_code_hash = data.archive_file.cognito-sign-in-trigger.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      CUSTOMER_API_BASE_URL = "https://customerprtlbe.${var.env}.prioritywaste.com"
    }
  }

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }



  tags = var.tags
}


#############################################################################################################################


data "archive_file" "sign-in-trigger-update" {
  type        = "zip"
  source_file = "${path.module}/functions/signin-trigger-env-vars-update.mjs"
  output_path = "${path.module}/functions/signin-trigger-env-vars-update.zip"
}

resource "aws_lambda_function" "sign-in-trigger-update" {
  filename      = "${path.module}/functions/signin-trigger-env-vars-update.zip"
  function_name = "pw-lambda-${var.env}-sign-in-trigger-update"
  role          = var.sign-in-trigger-update-role-arn
  handler       = "signin-trigger-env-vars-update.handler"
  timeout       = 60

  source_code_hash = data.archive_file.sign-in-trigger-update.output_base64sha256

  runtime = "nodejs20.x"

  environment {
    variables = {
      USER_POOL_ID = var.cognito-user-pool-id
      FUNCTION_NAME = aws_lambda_function.cognito-sign-in-trigger.function_name
    }
  }

  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }


  tags = var.tags
}

resource "aws_lambda_invocation" "sign-in-trigger-update-lambda-invocation" {
  function_name = aws_lambda_function.sign-in-trigger-update.function_name

  input = jsonencode({
    not = "required"
  })
}


#############################################################################################################################


data "archive_file" "jobstatus-change-ws" {
  type        = "zip"
  source_file = "${path.module}/functions/jobstatus-change-ws.py"
  output_path = "${path.module}/functions/jobstatus-change-ws.zip"
}

resource "aws_lambda_function" "jobstatus-change-ws" {
  filename      = "${path.module}/functions/jobstatus-change-ws.zip"
  function_name = "pw-lambda-${var.env}-jobstatus-change-ws"
  handler          = "jobstatus-change-ws.lambda_handler"
  timeout       = 60
  role             = var.jobstatus-change-ws-role-arn

  source_code_hash = data.archive_file.jobstatus-change-ws.output_base64sha256

  runtime          = "python3.9"


  vpc_config {
    subnet_ids         = [data.aws_subnet.private_az1.id, data.aws_subnet.private_az2.id]
    security_group_ids = [var.lambda_security_group_id]
  }


  tags = var.tags
}


##########################################
# Event Source Mapping
##########################################

resource "aws_lambda_event_source_mapping" "jobstatus-change-ws-ddb_event_source" {
  event_source_arn  = var.jobs-table-arn
  function_name     = aws_lambda_function.jobstatus-change-ws.function_name
  starting_position = "LATEST"
  batch_size        = 100
  enabled           = true
}