output "s3-mobile-app-arn" {
  value = aws_s3_bucket.s3-bucket.arn
}

output "s3-upload-backend-arn" {
  value = aws_s3_bucket.upload.arn
}

output "s3_kms_key_arn" {
  value = aws_kms_key.s3-encryption.arn
}