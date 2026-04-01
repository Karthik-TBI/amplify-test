
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

##############################################################################################


resource "aws_kms_key" "dynamodb_cmk" {
  description             = "KMS CMK for encrypting DynamoDB tables"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "pw-portal-dynamodb-cmk"
  })
}

resource "aws_kms_alias" "dynamodb_cmk_alias" {
  name          = "alias/portal-dynamodb-cmk"
  target_key_id = aws_kms_key.dynamodb_cmk.id
  
}

##################################################################################################################################

resource "aws_kms_key" "backup_vault_key" {
  description             = "KMS CMK for encrypting AWS Backup Vault"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "pw-portal-dynamodb-backup-cmk"
  })
}

resource "aws_kms_alias" "backup_vault_alias" {
  name          = "alias/portal-backup-vault-key"
  target_key_id = aws_kms_key.backup_vault_key.id
}


##################################################################################################################################

resource "aws_dynamodb_table" "appsync-db-table" {
  name           = "pw-dynamodb-${var.env}-location"
  billing_mode             = "PAY_PER_REQUEST"
  # billing_mode   = "PROVISIONED"
  # read_capacity  = 5
  # write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}


##################################################################################################################################

# New DynamoDB Table for Routes for driver app
resource "aws_dynamodb_table" "routes-db-table" {
  name                     = "pw-portal-${var.env}-routes"
  billing_mode             = "PAY_PER_REQUEST"
  # read_capacity  = 5
  # write_capacity = 5
  hash_key                 = "route_number"
  range_key                = "created_date"
  

  attribute {
    name = "route_number"
    type = "S"
  }

  attribute {
    name = "created_date"
    type = "S" #string
  }

 deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}

##################################################################################################################################

# New DynamoDB Table for jobs
resource "aws_dynamodb_table" "jobs-db-table" {
  name                     = "pw-portal-${var.env}-jobs"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "job_id"
  range_key                = "created_date"

  attribute {
    name = "job_id"
    type = "S"
  }

  attribute {
    name = "created_date"
    type = "S" #string
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  
  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}



# ##################################################################################################################################

# # New DynamoDB Table for job details
# resource "aws_dynamodb_table" "job_details-db-table" {
#   name                     = "pw-portal-${var.env}-Job_Details"
#   billing_mode             = "PAY_PER_REQUEST"
#   hash_key                 = "job_detail_id"
#   range_key                = "job_id"
 

#   attribute {
#     name = "job_detail_id"
#     type = "S"
#   }

#   attribute {
#     name = "job_id"
#     type = "S" #string
#   }

#   deletion_protection_enabled = true

#   point_in_time_recovery {
#     enabled = true
#   }

#   server_side_encryption {
#     enabled     = true
#     kms_key_arn = aws_kms_key.dynamodb_cmk.arn
#   }

#   tags = var.tags
# }


# ##################################################################################################################################

# # New DynamoDB Table for Vehicle details
resource "aws_dynamodb_table" "vehicle_inspections-db-table" {
  name                     = "pw-portal-${var.env}-Vehicle_Inspections"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "inspection_id"
  range_key                = "vehicle_id"
  

  attribute {
    name = "inspection_id"
    type = "S"
  }

  attribute {
    name = "vehicle_id"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}


##################################################################################################################################

# New DynamoDB Table for rejection details
resource "aws_dynamodb_table" "Rejection-db-table" {
  name                     = "pw-portal-${var.env}-reject-job-reasons"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "reason_id"
  

  attribute {
    name = "reason_id"
    type = "S"
  }


  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}



##################################################################################################################################

# New DynamoDB Table for Records disposal operations
resource "aws_dynamodb_table" "Records-disposal-operations-db-table" {
  name                     = "pw-portal-${var.env}-disposal-operations"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "disposal_id"
  range_key                = "created_date"
  

  attribute {
    name = "disposal_id"
    type = "S"
  }

  attribute {
    name = "created_date"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}




##################################################################################################################################


# New DynamoDB Table for Catalogs different types of waste materials
resource "aws_dynamodb_table" "waste-materials-db-table" {
  name                     = "pw-portal-${var.env}-waste-materials"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "material_id"
  range_key                = "name"
  

  attribute {
    name = "material_id"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}


##################################################################################################################################


# New DynamoDB Table for Manages disposal location information
resource "aws_dynamodb_table" "disposal-sites-db-table" {
  name                     = "pw-portal-${var.env}-disposal-sites"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "site_id"
  range_key                = "site_name"

  attribute {
    name = "site_id"
    type = "S"
  }

  attribute {
    name = "site_name"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}

##################################################################################################################################
##################################################################################################################################

# New DynamoDB Table for route-leave-reasons
resource "aws_dynamodb_table" "route-leave-reasons-db-table" {
  name                     = "pw-portal-${var.env}-route-leave-reasons"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "reason_id"
  # range_key                = "job_id"
  

  attribute {
    name = "reason_id"
    type = "S"
  }

  # attribute {
  #   name = "job_id"
  #   type = "S" #string
  # }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}


##################################################################################################################################

# New DynamoDB Table for notifications
resource "aws_dynamodb_table" "notifications-db-table" {
  name                     = "pw-portal-${var.env}-notifications"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "notification_id"
  range_key                = "created_date"
  

  attribute {
    name = "notification_id"
    type = "S"
  }

  attribute {
    name = "created_date"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}

##################################################################################################################################

# New DynamoDB Table for notifications
resource "aws_dynamodb_table" "reject-job-history-db-table" {
  name                     = "pw-portal-${var.env}-reject-job-history"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "rejected_job_history_id"
  # range_key                = "created_date"
  

  attribute {
    name = "rejected_job_history_id"
    type = "S"
  }

  # attribute {
  #   name = "created_date"
  #   type = "S" #string
  # }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}


##################################################################################################################################

# DynamoDB Table for jobs-audit
resource "aws_dynamodb_table" "jobs-audit-db-table" {
  name                     = "pw-portal-${var.env}-jobs-audit"
  billing_mode             = "PAY_PER_REQUEST"
  hash_key                 = "job_audit_id"
  range_key                = "job_id"
  

  attribute {
    name = "job_audit_id"
    type = "S"
  }

  attribute {
    name = "job_id"
    type = "S" #string
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamodb_cmk.arn
  }

  tags = var.tags
}





##################################################################################################################################


##################################################################################################################################



#Back up plan for DynamoDB ------------------------------------------------------
resource "aws_backup_vault" "dynamodb_backup" {
  name        = "pw-portal-dynamodb_backup-${var.env}"
  kms_key_arn = aws_kms_key.backup_vault_key.arn
  tags        = var.tags
}

resource "aws_backup_plan" "dynamodb_backup" {
  name = "pw-portal-dynamodb_backup_plan-${var.env}"

  rule {
    rule_name         = "pw-portal-dynamodb_backup_rule"
    target_vault_name = aws_backup_vault.dynamodb_backup.name
    # schedule          = "cron(0 12 * * ? *)"
    schedule          = "cron(0 0 * * ? *)"

    lifecycle {
      delete_after = 14
    }
  }

   tags = var.tags
}

resource "aws_backup_selection" "dynamodb_backup" {
  iam_role_arn = aws_iam_role.backup_role.arn
  name         = "pw-dynamodb_backup_selection-${var.env}"
  plan_id      = aws_backup_plan.dynamodb_backup.id

  resources = [
    aws_dynamodb_table.appsync-db-table.arn ,
    aws_dynamodb_table.routes-db-table.arn ,
    aws_dynamodb_table.jobs-db-table.arn,
    # aws_dynamodb_table.job_details-db-table.arn ,
    aws_dynamodb_table.vehicle_inspections-db-table.arn ,
    aws_dynamodb_table.Rejection-db-table.arn,
    aws_dynamodb_table.Records-disposal-operations-db-table.arn ,
    aws_dynamodb_table.waste-materials-db-table.arn ,
    aws_dynamodb_table.route-leave-reasons-db-table.arn,
    aws_dynamodb_table.disposal-sites-db-table.arn,
    aws_dynamodb_table.notifications-db-table.arn,
    aws_dynamodb_table.reject-job-history-db-table.arn,
    aws_dynamodb_table.jobs-audit-db-table.arn
  ]
}

resource "aws_iam_role" "backup_role" {
  name = "pw-backuprole-dynamodb-${var.env}"
  tags = var.tags

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "backup.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : "backup.amazonaws.com"
        }
        Action : "sts:AssumeRole",
        Condition: {
          StringEquals: {
            "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
          }
        }
      }
    ]
  })
}
# resource "aws_iam_role_policy" "backup_role_policy" {
#   name   = "pw-portal-dbbackup-role-policy"
#   role   = aws_iam_role.backup_role.id
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action   = [
#           "dynamodb:ListTables",
#           "dynamodb:DescribeTable",
#           "dynamodb:ListBackups",
#           "dynamodb:ListTagsOfResource",
#           "dynamodb:CreateBackup",
#           "dynamodb:DeleteBackup",
#           "dynamodb:RestoreTableFromBackup"
#         ]
#         Effect   = "Allow"
#         Resource = [
#           aws_backup_vault.dynamodb_backup.arn
#         ]
#       }
#     ]
#   })
# }


resource "aws_iam_role_policy" "backup_role_policy" {
  name = "pw-portal-dbbackup-role-policy"
  role = aws_iam_role.backup_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:CreateBackup",
          "dynamodb:DeleteBackup",
          "dynamodb:DescribeBackup",
          "dynamodb:DescribeTable",
          "dynamodb:ListTagsOfResource",  # Added this permission
          "dynamodb:ListBackups",
          "dynamodb:DescribeTable",
          "dynamodb:ListTables",
          "dynamodb:StartAwsBackupJob"
        ]
        Resource = [
          aws_dynamodb_table.appsync-db-table.arn,
          aws_dynamodb_table.routes-db-table.arn,
          aws_dynamodb_table.jobs-db-table.arn,
          # aws_dynamodb_table.job_details-db-table.arn,
          aws_dynamodb_table.vehicle_inspections-db-table.arn,
          aws_dynamodb_table.Rejection-db-table.arn,
          aws_dynamodb_table.Records-disposal-operations-db-table.arn,
          aws_dynamodb_table.waste-materials-db-table.arn,
          aws_dynamodb_table.disposal-sites-db-table.arn,
          aws_dynamodb_table.notifications-db-table.arn,
          aws_dynamodb_table.reject-job-history-db-table.arn,
          aws_dynamodb_table.jobs-audit-db-table.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "backup:StartBackupJob",
          "backup:DescribeBackupJob",
          "backup:CreateBackupSelection",
          "backup:GetBackupVault",
          "backup:StopBackupJob",
          "backup:CreateBackupPlan",
          "backup:DeleteBackupPlan",
          "backup:UpdateBackupPlan",
          "backup:ListBackupJobs",
          "backup:GetBackupVaultAccessPolicy"
        ]
        # Resource = "*"
        Resource = [aws_backup_plan.dynamodb_backup.arn]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = [
          aws_kms_key.backup_vault_key.arn,
          aws_kms_key.dynamodb_cmk.arn
        ]
      }
    ]
  })
}











