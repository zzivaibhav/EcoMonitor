# SNS Topic for Error Notifications
resource "aws_sns_topic" "ecomonitor_errors" {
  name = "ecomonitor-error-notifications"
  
  tags = {
    Name        = "EcoMonitor Error Notifications"
    Description = "Notifies developers of errors in the EcoMonitor system"
    Project     = "EcoMonitor"
  }
}

# SNS Topic Policy - allows services to publish to this topic
resource "aws_sns_topic_policy" "ecomonitor_errors_policy" {
  arn    = aws_sns_topic.ecomonitor_errors.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Effect    = "Allow"
        Principal = { Service = "iot.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Effect    = "Allow"
        Principal = { Service = "dynamodb.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      }
    ]
  })
}

# Optional: Create an email subscription for the admin
# Uncomment and modify with your email address to enable
# resource "aws_sns_topic_subscription" "admin_email" {
#   topic_arn = aws_sns_topic.ecomonitor_errors.arn
#   protocol  = "email"
#   endpoint  = "admin@example.com"
# }
