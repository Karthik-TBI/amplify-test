# Data source for existing logs bucket
data "aws_s3_bucket" "access_logs" {
  bucket = "pw-access-logs-${var.env}"
}

#############################################################################################
                        # kms key for the  encryption
############################################################################################
resource "aws_kms_key" "s3-encryption" {
  description             = "KMS CMK for encrypting s3 encryption "
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "pw-portal-s3-encryption"
  })
}

resource "aws_kms_alias" "s3-encryptionalias" {
  name          = "alias/pw-portal-s3-encryption"
  target_key_id = aws_kms_key.s3-encryption.id
}


################################################################################################




########################################################################################################



resource "aws_s3_bucket" "s3-bucket" {
  bucket = "pw-s3-${var.env}-mobile-app"

  tags = var.tags
}


# Enable versioning
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.s3-bucket.id
  versioning_configuration {
    status = "Enabled"
    mfa_delete = "Disabled"
  }
}


resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.s3-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# # Enable KMS encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3-bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-encryption.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# # S3 Bucket Notification Configuration
# resource "aws_s3_bucket_notification" "mobileapp_bucket_notification" {
#   bucket = aws_s3_bucket.s3-bucket.id

#   topic {
#     topic_arn = var.topic_arn
#     events    = [
#       "s3:ObjectRemoved:Delete",
#       "s3:ObjectRemoved:DeleteMarkerCreated"
#     ]
#   }


# }

# # S3 Bucket Notification Configuration
# resource "aws_s3_bucket_notification" "mobileapp_bucket_notification" {
#   bucket = aws_s3_bucket.s3-bucket.id

#   # Use a dynamic block for more robust configuration
#   dynamic "topic" {
#     for_each = var.topic_arn != null ? [1] : []
#     content {
#       topic_arn = var.topic_arn
#       events    = [
#         "s3:ObjectRemoved:Delete",
#         "s3:ObjectRemoved:DeleteMarkerCreated"
#       ]
#     }
#   }
# }

# # Enable lifecycle rules
# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
#   bucket = aws_s3_bucket.s3-bucket.id

#   rule {
#     id     = "archive_old_objects"
#     status = "Enabled"

#     transition {
#       days          = 90
#       storage_class = "STANDARD_IA"
#     }
#   }
# }



# # Enable logging on the source bucket
resource "aws_s3_bucket_logging" "frontend" {
  bucket = aws_s3_bucket.s3-bucket.id
  target_bucket = data.aws_s3_bucket.access_logs.id
  target_prefix = "${aws_s3_bucket.s3-bucket.bucket}-log/"
}





resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.s3-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-s3-${var.env}-mobile-app",
          "arn:aws:s3:::pw-s3-${var.env}-mobile-app/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

}




#######################################################################################

resource "aws_s3_bucket" "upload" {
  bucket = "pw-s3-${var.env}-upload-backend"
  # object_lock_enabled = true
  force_destroy = false
  tags = var.tags
}


# Enable versioning
resource "aws_s3_bucket_versioning" "versioning-upload" {
  bucket = aws_s3_bucket.upload.id
  versioning_configuration {
    status = "Enabled"
    mfa_delete = "Disabled"
  }
}


resource "aws_s3_bucket_public_access_block" "upload" {
  bucket = aws_s3_bucket.upload.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# # Enable KMS encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption-upload" {
  bucket = aws_s3_bucket.upload.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-encryption.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# S3 Bucket Notification Configuration
resource "aws_s3_bucket_notification" "upload_bucket_notification" {
  bucket = aws_s3_bucket.upload.id

  topic {
    topic_arn = var.topic_arn
    events    = [
      "s3:ObjectRemoved:Delete",
      "s3:ObjectRemoved:DeleteMarkerCreated"
    ]
  }


}

# # Enable lifecycle rules
# resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
#   bucket = aws_s3_bucket.s3-bucket.id

#   rule {
#     id     = "archive_old_objects"
#     status = "Enabled"

#     transition {
#       days          = 90
#       storage_class = "STANDARD_IA"
#     }
#   }
# }



# # Enable logging on the source bucket
resource "aws_s3_bucket_logging" "upload" {
  bucket = aws_s3_bucket.upload.id
  target_bucket = data.aws_s3_bucket.access_logs.id
  target_prefix = "${aws_s3_bucket.upload.bucket}-log/"
}





resource "aws_s3_bucket_policy" "upload" {
  bucket = aws_s3_bucket.upload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-s3-${var.env}-upload-backend",
          "arn:aws:s3:::pw-s3-${var.env}-upload-backend/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

}























# resource "aws_s3_bucket_policy" "voicemail" {
#   bucket = aws_s3_bucket.voicemail.id
#   policy = data.aws_iam_policy_document.voicemail.json
# }

# resource "aws_s3_object" "templates" {
#   for_each = { for file in var.template_files : file.key => file }
#   bucket = aws_s3_bucket.voicemail.bucket
#   key    = each.value.key
#   source = each.value.source
#   acl    = "private"
# }

# resource "aws_s3_bucket" "glue_jobs" {
#   bucket = "pw-glue-jobs-${var.env}"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_object_lock_configuration" "glue_jobs_object_lock_configuration" {
#   bucket = aws_s3_bucket.glue_jobs.id

#   rule {
#     default_retention {
#       mode = "COMPLIANCE"
#       days = 5
#     }
#   }
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "glue_jobs_aws_s3_bucket_server_side_encryption_configuration" {
#   bucket = aws_s3_bucket.glue_jobs.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.s3_key.arn
#       sse_algorithm = "aws:kms"
#     }
#     bucket_key_enabled = true
#   }
# }

# resource "aws_s3_bucket_lifecycle_configuration" "glue_jobs_lifecycle" {
#   bucket = aws_s3_bucket.glue_jobs.id

#   rule {
#     id     = "cases-data"
#     status = "Enabled"

#     filter {
#       prefix = "output/"
#     }

#     transition {
#       days          = 90
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = 455 
#     }
#   }
# }




