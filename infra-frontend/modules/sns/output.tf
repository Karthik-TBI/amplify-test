output "topic_arn" {
  description = "ARN of the SNS Topic for S3 event notifications"
  value       = aws_sns_topic.event_notifications.arn
}

output "topic_name" {
  description = "Name of the SNS Topic for S3 event notifications"
  value       = aws_sns_topic.event_notifications.name
}

output "topic_policy_id" {
  description = "ID of the SNS Topic Policy"
  value       = aws_sns_topic_policy.event_notifications.id
}

