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
        Sid       = "AllowLambdaPublish"
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Sid       = "AllowIoTPublish"
        Effect    = "Allow"
        Principal = { Service = "iot.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Sid       = "AllowDynamoDBPublish"
        Effect    = "Allow"
        Principal = { Service = "dynamodb.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      },
      {
        Sid       = "AllowS3Publish"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecomonitor_errors.arn
      }
    ]
  })
}

# Email subscription for error notifications
# To enable email notifications:
# 1. Uncomment the resource below
# 2. Replace "your.email@example.com" with your actual email address
# 3. Run 'terraform apply'
# 4. Check your email and confirm the subscription
# 
# resource "aws_sns_topic_subscription" "admin_email" {
#   topic_arn = aws_sns_topic.ecomonitor_errors.arn
#   protocol  = "email"
#   endpoint  = "your.email@example.com"
# }
