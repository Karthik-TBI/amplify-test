data "aws_caller_identity" "current" {}

# Create SNS Topic for S3 delete notifications
resource "aws_sns_topic" "event_notifications" {
  name = "pw-portal-notifications-${var.env}"
  
  tags = merge(
    var.tags,
    {
      Name = "pw-portal-notifications-${var.env}"
    }
  )
}

# SNS Topic Policy to allow S3 to publish
resource "aws_sns_topic_policy" "event_notifications" {
  arn = aws_sns_topic.event_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "SNS:Publish"
        Resource = aws_sns_topic.event_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::pw-s3-${var.env}-mobile-app",
            "aws:SourceArn" = "arn:aws:s3:::pw-s3-${var.env}-upload-backend"
          }
        }
      }
    ]
  })
}