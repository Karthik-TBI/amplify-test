# Region
region = "ap-southeast-1"

# Tags
tags = {
  app   = "tbi-test"
  env   = "test"
  owner = "infra"
}



# --- Routes (all non-OPTIONS shown in your screenshots) ---
# Integration timeout and PFV are set per your screenshots (30s & 2.0)
routes = [
  { method = "POST", path = "/auth/send-otp", lambda_key = "external", auth = false, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "POST", path = "/auth/verify-otp", lambda_key = "external", auth = false, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "GET", path = "/cases", lambda_key = "cases", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "PUT", path = "/cases", lambda_key = "cases", auth = false, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "DELETE", path = "/cases", lambda_key = "cases", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "POST", path = "/uploads/{proxy+}", lambda_key = "uploads", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "POST", path = "/signedUrl", lambda_key = "urls", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "POST",    path = "/cases/{caseNumber}/evidence",lambda_key = "evidence", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "GET",    path = "/cases/{caseNumber}/evidence",lambda_key = "evidence", auth = true, timeout_ms = 30000, payload_format_version = "2.0" },
  { method = "DELETE", path = "/cases/{caseNumber}/evidence",lambda_key = "evidence", auth = true, timeout_ms = 30000, payload_format_version = "2.0" }
]

# --- HTTP API name ---
api_name = "tbi-test-api"

# --- CORS (exactly as your screenshot) ---
cors = {
  allow_origins     = ["https://master.d22xm0tzpcj3nx.amplifyapp.com"]
  allow_headers     = ["authorization", "content-type"]
  allow_methods     = ["GET", "POST", "OPTIONS", "PUT", "DELETE"]
  expose_headers    = []
  allow_credentials = false
  max_age           = 0
}

# --- Authorizer (JWT) ---
cognito_user_pool_name = "amplifyAuthUserPool4BA7F805-Hr0mPVa0i4CJ"
authorizer = {
  name            = "dev-cognito-authorizer"
  identity_source = "$request.header.Authorization"
  # Supply your *new* us-west-2 pool details (or whatever issuer/appClient you plan to use for this stack):
  # issuer   = "https://cognito-idp.us-west-2.amazonaws.com/us-west-2_gN5rACu1A"
  # audience = ["4it562oiaikqohgr31nd0aa6n0"]
}

# --- Stages ---
stages = {
  create_default      = true
  default_auto_deploy = true
  create_dev          = true
  dev_auto_deploy     = false
}



# -----------------------
# IAM roles (one per Lambda)
# -----------------------
# We replicate your current broad permissions exactly.
# - handleExternalUser: DDB Full, DDB Full v2, SES Full, Lambda Basic Execution
# - manageCaseInDynamoDB: DDB Full, Lambda Basic Execution
#
# IMPORTANT: Confirm/replace ARNs below as needed.

iam_roles = {
  external = {
    role_name = "handleExternalUser-role-dev"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
      # If your account really uses the v2 managed policy, add its exact ARN here:
      # e.g., "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess_v2"
      # Otherwise, you can remove the line below.
      "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess", # placeholder for v2 if you don't have the ARN
      "arn:aws:iam::aws:policy/AmazonSESFullAccess",
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
  }

  cases = {
    role_name = "manageCaseInDynamoDB-role-dev"
    managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
      "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
  }

  evidence = {
    role_name = "getCaseEvidenceLambda-role-dev"
    managed_policy_arns = [
            "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
            "arn:aws:iam::aws:policy/AmazonS3FullAccess",
            "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
  }

  uploads = {
    role_name = "multipartUploadToS3-role-dev"
    managed_policy_arns = [
            "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
            "arn:aws:iam::aws:policy/AmazonS3FullAccess",
            "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    ]
  }

    urls = {
      role_name = "generatePreSignedUrl-role-dev"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
            "arn:aws:iam::aws:policy/AmazonS3FullAccess",
            "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

    updateCaseSizeDynamoDB = {
      role_name = "updateCaseSizeDynamoDB-role-dev"
      managed_policy_arns = [
        "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
            "arn:aws:iam::aws:policy/AmazonS3FullAccess",
            "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
      ]
    }

  }

# -----------------------
# Lambdas (local ZIP packaging)
# -----------------------
# We mirror the runtime/handler/memory/timeout/arch and env vars exactly as shown.
# Timeout remains 3s for both (as you requested).
# X-Ray disabled for both.

lambdas = {
  external = {
    role_key         = "external" # uses iam_roles.external
    function_name    = "handleExternalUser"
    description      = "Handles /auth/send-otp and /auth/verify-otp"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/handleExternalUser/lambda_function.py"
    package_filename = "../../modules/lambdas/functions/handleExternalUser/lambda_function.py"
    env_vars = {
      OTP_TABLE_NAME     = "externalUserOtp"
      SESSION_TABLE_NAME = "externalUserSessions"
      SENDER_EMAIL       = "noreply@tbi.trianz.com"
    }
    log_retention_days = 30
    enable_xray        = false
  }

  cases = {
    role_key         = "cases" # uses iam_roles.cases
    function_name    = "manageCaseInDynamoDB"
    description      = "Handles /cases (GET/PUT/DELETE)"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/zips/manageCaseInDynamoDB.zip"
    package_filename = "../../modules/lambdas/functions/manageCaseInDynamoDB/lambda_function.py"
    env_vars = {
      CASE_REGISTRY_TABLE = "CaseNumberRegistry"
      CASE_TABLE          = "TbiCaseRepositories"
      RECEIVED_CASE_TABLE = "ReceivedCases"
    }
    log_retention_days = 30
    enable_xray        = false
  }

  evidence = {
    role_key         = "evidence" # uses iam_roles.evidence
    function_name    = "getCaseEvidenceLambda"
    description      = "Handles /evidences (GET/POST/DELETE)"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/zips/getCaseEvidenceLambda.zip"
    package_filename = "../../modules/lambdas/functions/getCaseEvidenceLambda/lambda_function.py"
    env_vars = {
      BUCKET = "amplify-d22xm0tzpcj3nx-mas-mystoragebucket472d5355-pepvyjkfh4qr"
      EVIDENCE_TABLE          = "CaseEvidenceIndex"
    }
    log_retention_days = 30
    enable_xray        = false
  }

  uploads = {
    role_key         = "uploads" # uses iam_roles.uploads
    function_name    = "multiPartUploadToS3"
    description      = "Handles POST to s3 (multi-files)"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/zips/multiPartUploadToS3.zip"
    package_filename = "../../modules/lambdas/functions/multipartUploadToS3/lambda_function.py"
    env_vars = {
     BUCKET = "amplify-d22xm0tzpcj3nx-mas-mystoragebucket472d5355-pepvyjkfh4qr"
    CASE_TABLE = "TbiCaseRepositories"
    RECEIVED_CASE_TABLE = "ReceivedCases"
    }
    log_retention_days = 30
    enable_xray        = false
  }

  urls = {
    role_key         = "urls" # uses iam_roles.signedUrls
    function_name    = "generatetePreSignedUrls"
    description      = "Handles /evidences (GET/POST/DELETE)"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/zips/generatePreSignedUrl.zip"
    package_filename = "../../modules/lambdas/functions/generatePreSignedUrl/lambda_function.py"
     env_vars = {
      BUCKET = "amplify-d22xm0tzpcj3nx-mas-mystoragebucket472d5355-pepvyjkfh4qr"
      CASE_TABLE = "TbiCaseRepositories"
      RECEIVED_CASE_TABLE = "ReceivedCases"
    }
    log_retention_days = 30
    enable_xray        = false
  }

  updateCaseSizeDynamoDB = {
    role_key = "updateCaseSizeDynamoDB"
     function_name    = "updateCaseSizeDynamoDB"
    description      = "Handles case size updates and metadata"
    runtime          = "python3.12"
    handler          = "lambda_function.lambda_handler"
    memory_size      = 128
    timeout          = 3
    architectures    = ["x86_64"]
    # package_filename = "../../lambdas/zips/updateCaseSizeDynamoDB.zip"
    package_filename = "../../modules/lambdas/functions/updateCaseSizeDynamoDB/lambda_function.py"
     env_vars = {
      CASE_TABLE = "TbiCaseRepositories",
      EVIDENCE_TABLE = "CaseEvidenceIndex"
      OBJECT_INDEX_TABLE = "CaseObjectIndex"
      RECEIVED_CASE_TABLE = "ReceivedCases"
    }
    log_retention_days = 30
    enable_xray        = false
  }
}


# ─────────────────────────────────────────────────────────────
# DYNAMODB TABLES
# PITR = Off, Streams = Off for all three
# ─────────────────────────────────────────────────────────────
dynamodb_tables = {
  case_registry = {
    name         = "CaseNumberRegistry"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = { name = "case_number", type = "S" }
    # No sort key
    global_secondary_indexes = []
    pitr_enabled             = false
    ttl                      = { enabled = false }
    stream_enabled           = false
    # stream_view_type omitted (not needed when disabled)
  }

  tbi_case_repositories = {
    name         = "TbiCaseRepositories"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = { name = "user_name", type = "S" }
    range_key    = { name = "case_number", type = "S" }

    global_secondary_indexes = [
      {
        name            = "AccessByEmailIndex"
        hash_key        = { name = "access_email", type = "S" }
        range_key       = { name = "case_number", type = "S" }
        projection_type = "ALL"
        # non_key_attributes only if projection_type = "INCLUDE"
      }
    ]

    pitr_enabled   = false
    ttl            = { enabled = false }
    stream_enabled = false
  }

  received_cases = {
    name         = "ReceivedCases"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = { name = "receiver_user_id", type = "S" }
    range_key    = { name = "case_number", type = "S" }

    global_secondary_indexes = [
      {
        name            = "gsi1"
        hash_key        = { name = "gsi1pk", type = "S" }
        range_key       = { name = "gsi1sk", type = "S" }
        projection_type = "ALL"
      }
    ]

    pitr_enabled   = false
    ttl            = { enabled = false }
    stream_enabled = false
  }

  case_evidence_index = {
    name         = "CaseEvidenceIndex"
    billing_mode = "PAY_PER_REQUEST"
    hash_key     = { name = "PK", type = "S" }
    range_key    = { name = "SK", type = "S" }

    global_secondary_indexes = [
      # {
      #   name            = "gsi2"
      #   hash_key        = { name = "gsi2pk", type = "S" }
      #   range_key       = { name = "gsi2sk", type = "S" }
      #   projection_type = "ALL"
      # }
    ]

    pitr_enabled   = false
    ttl            = { enabled = false }
    stream_enabled = false
  }

  case_object_index = {
    name = "CaseObjectIndex"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = {name = "object_id", type = "S"}
    # No sort key
    global_secondary_indexes = []
    pitr_enabled             = false
    ttl                      = { enabled = false }
    stream_enabled           = false
    # stream_view_type omitted (not needed when disabled)
  }
}