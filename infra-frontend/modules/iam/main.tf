# Required data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get the secret values from existing secret
data "aws_secretsmanager_secret" "netsuite" {
  arn = var.netsuite_secret_arn
}

##########################################################################################


# resource "aws_iam_role" "appsync-dynamo-access-role" {
#   name = "pw-iam-role-${var.env}-appsync-dynamo-access"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "appsync.amazonaws.com"
#         }
#       }
#     ]
#   })

#   inline_policy {
#     name = "pw-iam-policy-${var.env}-appsync-dynamo-access"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = [
#             "dynamodb:DeleteItem",
#             "dynamodb:GetItem",
#             "dynamodb:PutItem",
#             "dynamodb:Query",
#             "dynamodb:Scan",
#             "dynamodb:UpdateItem"
#          ]
#           Effect   = "Allow"
#           Resource = [
#             "${var.dynamo-table-arn}",
#             "${var.dynamo-table-arn}/*"
#           ]
#         },
#       ]
#     })
#   }

#   tags = var.tags
# }



#######################################################################################

resource "aws_iam_role" "devicefarm-s3-access-role" {
  name = "pw-iam-role-${var.env}-devicefarm-s3-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "pw-iam-policy-${var.env}-devicefarm-s3-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
            "logs:*"
         ]
          Effect   = "Allow"
          Resource = [
            "*"
          ]
        },
        {
          Action   = [
            "devicefarm:CreateUpload",
            "devicefarm:GetUpload",
            "devicefarm:ScheduleRun"
         ]
          Effect   = "Allow"
          Resource = [
            "*"
          ]
        },
        {
          Action   = [
            "s3:GetObject"
         ]
          Effect   = "Allow"
          Resource = [
            "${var.s3-bucket-arn}",
            "${var.s3-bucket-arn}/*"
          ]
        }
      ]
    })
  }

  tags = var.tags
}

# VPC access policy
resource "aws_iam_role_policy_attachment" "lambda_vpc_devicefarm" {
  role       = aws_iam_role.devicefarm-s3-access-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


###########################################################################################

resource "aws_iam_role" "cognito-sign-up-trigger-role" {
  name = "pw-iam-role-${var.env}-cognito-sign-up-trigger"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Add inline policy for Secrets Manager and KMS access
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "lambda-secrets-policy"
  role = aws_iam_role.cognito-sign-up-trigger-role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          data.aws_secretsmanager_secret.netsuite.arn,
          var.s3_kms_key_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
  
}

# Basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.cognito-sign-up-trigger-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC access policy
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.cognito-sign-up-trigger-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Additional VPC permissions
resource "aws_iam_role_policy" "lambda_vpc_policy" {
  name = "pw-vpc-policy-${var.env}-cognito-sign-up"
  role = aws_iam_role.cognito-sign-up-trigger-role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      }
    ]
  })
}


# # Secrets Manager access policy
# resource "aws_iam_role_policy" "lambda_secrets_manager_policy" {
#   name = "pw-secrets-manager-policy-${var.env}-cognito-sign-up"
#   role = aws_iam_role.cognito-sign-up-trigger-role.name

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "secretsmanager:GetSecretValue"
#         ]
#         Resource = [
#           "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:/pw/${var.env}/netsuite/credentials-*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt"
#         ]
#         # Adjust the KMS key ARN as needed
#         Resource = [
#           "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/*"
#         ]
#       }
#     ]
#   })
# }


# resource "aws_iam_role" "cognito-sign-up-trigger-role" {
#   name = "pw-iam-role-${var.env}-cognito-sign-up-trigger"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
#   role       = aws_iam_role.cognito-sign-up-trigger-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }



###########################################################################################################################

# IAM Role
resource "aws_iam_role" "cognito-sign-in-trigger-role" {
  name = "pw-iam-role-${var.env}-cognito-sign-in-trigger"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
          },
          StringLike = {
            "aws:SourceArn": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:pw-lambda-${var.env}-*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "pw-iam-role-${var.env}-cognito-sign-in-trigger"
  })
}

# IAM Policy
resource "aws_iam_policy" "cognito-sign-in-trigger-policy" {
  name = "pw-iam-policy-${var.env}-cognito-sign-in-trigger"
  description = "Policy for Cognito sign-in trigger Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/pw-lambda-${var.env}-*:*"
        ]
      },
      {
        Action = [
          "cognito-idp:AdminGetUser"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${var.cognito-user-pool-id}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": data.aws_region.current.name
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "pw-iam-policy-${var.env}-cognito-sign-in-trigger"
  })
}

# Attach custom policy to role
resource "aws_iam_role_policy_attachment" "cognito_sign_in_custom_policy" {
  role       = aws_iam_role.cognito-sign-in-trigger-role.name
  policy_arn = aws_iam_policy.cognito-sign-in-trigger-policy.arn
}

# Add AWS managed policy for VPC access
resource "aws_iam_role_policy_attachment" "cognito_sign_in_vpc_access" {
  role       = aws_iam_role.cognito-sign-in-trigger-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

###########################################################################################################################

# resource "aws_iam_role" "cognito-sign-in-trigger-role" {
#   name = "pw-iam-role-${var.env}-cognito-sign-in-trigger"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   inline_policy {
#     name = "pw-iam-policy-${var.env}-cognito-sign-in-trigger"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = [
#             "logs:*"
#           ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#         {
#           Action   = [
#             "cognito-idp:AdminGetUser"
#           ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#         {
#           Effect = "Allow"
#           Action = [
#             "ec2:CreateNetworkInterface",
#             "ec2:DescribeNetworkInterfaces",
#             "ec2:DeleteNetworkInterface",
#             "ec2:AssignPrivateIpAddresses",
#             "ec2:UnassignPrivateIpAddresses",
#             "ec2:DescribeSecurityGroups",
#             "ec2:DescribeSubnets",
#             "ec2:DescribeVpcs"
#           ]
#           Resource = "*"
#         }
#       ]
#     })
#   }

#   tags = var.tags
# }

# # Add AWS managed policy for VPC access
# resource "aws_iam_role_policy_attachment" "cognito_sign_in_vpc_access" {
#   role       = aws_iam_role.cognito-sign-in-trigger-role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }


##########################################################################################


# resource "aws_iam_role" "cognito-sign-in-trigger-role" {
#   name = "pw-iam-role-${var.env}-cognito-sign-in-trigger"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   inline_policy {
#     name = "pw-iam-policy-${var.env}-cognito-sign-in-trigger"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = [
#             "logs:*"
#          ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#         {
#           Action   = [
#             "cognito-idp:AdminGetUser"
#          ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#       ]
#     })
#   }

#   tags = var.tags
# }


####################################################################################################

# IAM Role
resource "aws_iam_role" "sign-in-trigger-update-role" {
  name = "pw-iam-role-${var.env}-sign-in-trigger-update"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceAccount": data.aws_caller_identity.current.account_id
          },
          StringLike = {
            "aws:SourceArn": "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:pw-lambda-${var.env}-*"
          }
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy
resource "aws_iam_policy" "sign-in-trigger-update-policy" {
  name        = "pw-iam-policy-${var.env}-sign-in-trigger-update"
  description = "Policy for sign-in trigger update Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/pw-lambda-${var.env}-*:*"
        ]
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:pw-lambda-${var.env}-*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces", 
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.region
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Attach custom policy to role
resource "aws_iam_role_policy_attachment" "sign_in_trigger_policy_attachment" {
  role       = aws_iam_role.sign-in-trigger-update-role.name
  policy_arn = aws_iam_policy.sign-in-trigger-update-policy.arn
}

# Attach AWS managed policy for VPC access
resource "aws_iam_role_policy_attachment" "lambda_vpc_acces" {
  role       = aws_iam_role.sign-in-trigger-update-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
####################################################################################################

# resource "aws_iam_role" "sign-in-trigger-update-role" {
#   name = "pw-iam-role-${var.env}-sign-in-trigger-update"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount": data.aws_caller_identity.current.account_id
#           }
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# resource "aws_iam_role_policy" "sign-in-trigger-update-policy" {
#   name = "pw-iam-policy-${var.env}-sign-in-trigger-update"
#   role = aws_iam_role.sign-in-trigger-update-role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream", 
#           "logs:PutLogEvents"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/pw-lambda-${var.env}-*:*"
#         ]
#       },
#       {
#         Action = [
#           "lambda:InvokeFunction",
#           "lambda:UpdateFunctionConfiguration",
#           "lambda:GetFunction",
#           "lambda:GetFunctionConfiguration"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:pw-lambda-${var.env}-*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateNetworkInterface",
#           "ec2:DescribeNetworkInterfaces", 
#           "ec2:DeleteNetworkInterface",
#           "ec2:AssignPrivateIpAddresses",
#           "ec2:UnassignPrivateIpAddresses",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeVpcs"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_vpc_acces" {
#   role       = aws_iam_role.sign-in-trigger-update-role.id
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }

####################################################################################################

# resource "aws_iam_role" "sign-in-trigger-update-role" {
#   name = "pw-iam-role-${var.env}-sign-in-trigger-update"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount": data.aws_caller_identity.current.account_id
#           }
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# resource "aws_iam_role_policy" "sign-in-trigger-update-policy" {
#   name = "pw-iam-policy-${var.env}-sign-in-trigger-update"
#   role = aws_iam_role.sign-in-trigger-update-role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.env}-*:*"
#         ]
#       },
#       {
#         Action = [
#           "lambda:InvokeFunction"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.env}-*"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
#   role       = aws_iam_role.sign-in-trigger-update-role.id
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }

# resource "aws_iam_role_policy" "lambda_vpc_policy" {
#   name = "pw-lambda-vpc-policy-${var.env}"
#   role = aws_iam_role.sign-in-trigger-update-role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:CreateNetworkInterface",
#           "ec2:DescribeNetworkInterfaces",
#           "ec2:DeleteNetworkInterface",
#           "ec2:AssignPrivateIpAddresses",
#           "ec2:UnassignPrivateIpAddresses"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

####################################################################################################


# resource "aws_iam_role" "sign-in-trigger-update-role" {
#   name = "pw-iam-role-${var.env}-sign-in-trigger-update"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         },
#         Condition = {
#           StringEquals = {
#             "aws:SourceAccount": data.aws_caller_identity.current.account_id
#           },
#           StringLike = {
#             "aws:SourceArn": "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.env}-*"
#           }
#         }
#       }
#     ]
#   })

#   tags = var.tags
# }

# # Separate IAM policy resource


# # Modified IAM policy resource
# resource "aws_iam_role_policy" "sign-in-trigger-update-policy" {
#   name = "pw-iam-policy-${var.env}-sign-in-trigger-update"
#   role = aws_iam_role.sign-in-trigger-update-role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:*"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.env}-*:*"
#         ]
#       },
#       {
#         Action = [
#           "lambda:*"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:${var.env}-*"
#         ]
#       }
#     ]
#   })
# }


####################################################################################################


# resource "aws_iam_role" "sign-in-trigger-update-role" {
#   name = "pw-iam-role-${var.env}-sign-in-trigger-update"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#       }
#     ]
#   })

#   inline_policy {
#     name = "pw-iam-policy-${var.env}-sign-in-trigger-update"
#     policy = jsonencode({
#       Version = "2012-10-17"
#       Statement = [
#         {
#           Action   = [
#             "logs:*"
#          ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#         {
#           Action   = [
#             "lambda:*"
#          ]
#           Effect   = "Allow"
#           Resource = [
#             "*"
#           ]
#         },
#       ]
#     })
#   }

#   tags = var.tags
# }


######################################################################################################################################################################

# jostatus change role
###################################################################################################################

# IAM Role
resource "aws_iam_role" "jobstatus-change-ws-role" {
  name = "pw-iam-role-${var.env}-jobstatus-change-ws"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
       
      }
    ]
  })

  tags = var.tags
}


# IAM Policy
resource "aws_iam_policy" "jobstatus-change-ws-policy" {
  name        = "pw-iam-policy-${var.env}-jobstatus-change-ws"
  description = "Policy for jobstatus-change-ws Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream", 
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/pw-lambda-${var.env}-jobstatus-change-ws"
        ]
      },
      {
        Action = [
          "lambda:InvokeFunction",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:function:pw-lambda-${var.env}-jobstatus-change-ws"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces", 
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      },
      {
        Action = [
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = [
          # "arn:aws:lambda:${var.region}:${data.aws_caller_identity.current.account_id}:table/pw-portal-${var.env}-jobs/stream/*"
          "*" 
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        # Resource = "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:alias/portal-dynamodb-cmk"
        Resource = var.dynamodb_cmk_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion": var.region
          }
        }
      }
    ]
  })

  tags = var.tags
}

# Add inline policy for Secrets Manager and KMS access
resource "aws_iam_role_policy" "scheduler_secrets" {
  name = "lambda-secrets-policy"
  role = aws_iam_role.jobstatus-change-ws-role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          var.scheduler_dispatcher_secret_arn,
          var.s3_kms_key_arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach custom policy to role
resource "aws_iam_role_policy_attachment" "jobstatus-change-ws_policy_attachment" {
  role       = aws_iam_role.jobstatus-change-ws-role.name
  policy_arn = aws_iam_policy.jobstatus-change-ws-policy.arn
}

# Attach AWS managed policy for VPC access
resource "aws_iam_role_policy_attachment" "jobstatus-change-ws-lambda_vpc_acces" {
  role       = aws_iam_role.jobstatus-change-ws-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}