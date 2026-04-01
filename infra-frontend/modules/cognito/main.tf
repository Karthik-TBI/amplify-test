resource "aws_cognito_user_pool" "user-pool" {

  name = "pw-cognito-${var.env}-user-pool"

    deletion_protection = "ACTIVE"
    auto_verified_attributes = ["email"]
    username_attributes = ["email"]

    # Advanced Security Configuration
    user_pool_add_ons {
        advanced_security_mode = "ENFORCED"
    }

    

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  device_configuration {
    challenge_required_on_new_device = true
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT" # "DEVELOPER"
    # from_email_address = 
    # source_arn = 
  }

  # sms_configuration {
  #   external_id = 
  #   sns_caller_arn = 
  # }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
  }

  schema {
    name = "phone_number"
    attribute_data_type = "String"
    mutable = true
    required = true
    developer_only_attribute = false
    string_attribute_constraints {
      min_length = "10"
      max_length = "15"
    }
  }

  schema {
    name = "name"
    attribute_data_type = "String"
    mutable = true
    required = true
    developer_only_attribute = false
    string_attribute_constraints {
      min_length = "1"
      max_length = "100"
    }
  }

  schema {
    name = "customer_id"
    attribute_data_type = "String"
    mutable = false
    required = false
    developer_only_attribute = false
    string_attribute_constraints {
      min_length = "1"
      max_length = "100"
    }
  }

  schema {
    name = "invoice_id"
    attribute_data_type = "String"
    mutable = false
    required = false
    developer_only_attribute = false
    string_attribute_constraints {
      min_length = "1"
      max_length = "100"
    }
  }

  user_attribute_update_settings {
    attributes_require_verification_before_update = ["email"]
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  lambda_config {
    pre_sign_up = var.pre-sign-up-lambda-arn
    pre_authentication = var.pre-sign-in-lambda-arn
  }

  tags = var.tags
}


resource "aws_cognito_user_pool_client" "user-pool-client" {
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  callback_urls                        = ["https:\\localhost"]
  default_redirect_uri                 = "https:\\localhost"
  explicit_auth_flows                  = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret                      = false
  logout_urls                          = ["https:\\localhost"]
  name                                 = "pw-cognito-${var.env}-client"
  # access_token_validity                = 1
  # id_token_validity                    = 1
  supported_identity_providers         = ["COGNITO"]
  prevent_user_existence_errors        = "ENABLED"
  user_pool_id                         = aws_cognito_user_pool.user-pool.id
}


resource "aws_cognito_user_pool_domain" "cognito-user-pool-domain" {
  domain       = "pw-${var.env}-domain"
  user_pool_id = aws_cognito_user_pool.user-pool.id
}

# resource "aws_cognito_user_pool_ui_customization" "cognito-ui-customization" {
#   user_pool_id = aws_cognito_user_pool_domain.cognito-user-pool-domain.user_pool_id
#   css          = ".label-customizable {font-weight: 400;}"
#   client_id    = aws_cognito_user_pool_client.user-pool-client.id
# }