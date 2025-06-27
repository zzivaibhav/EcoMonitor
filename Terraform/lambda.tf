# AWS Lambda Functions for IoT Device Simulation

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "iot_device_simulation_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda to publish to IoT topics and write logs
resource "aws_iam_policy" "lambda_iot_policy" {
  name        = "lambda_iot_publish_policy"
  description = "Allows Lambda functions to publish to IoT topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Subscribe",
          "iot:Receive"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "lambda_iot_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_iot_policy.arn
}

# Create ZIP archives for Lambda deployment packages
data "archive_file" "temperature_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/IoT devices/Temprature.py"
  output_path = "${path.module}/lambda_packages/temperature_function.zip"
}

data "archive_file" "humidity_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/IoT devices/Humidity.py"
  output_path = "${path.module}/lambda_packages/humidity_function.zip"
}

data "archive_file" "aqi_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/IoT devices/AQI.py"
  output_path = "${path.module}/lambda_packages/aqi_function.zip"
}

data "archive_file" "co2_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/IoT devices/Co2.py"
  output_path = "${path.module}/lambda_packages/co2_function.zip"
}

# Lambda function for temperature sensor simulation
resource "aws_lambda_function" "temperature_function" {
  function_name    = "temperature_sensor_simulator"
  filename         = data.archive_file.temperature_lambda_zip.output_path
  source_code_hash = data.archive_file.temperature_lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "Temprature.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10

  environment {
    variables = {
      IOT_ENDPOINT = data.aws_iot_endpoint.endpoint.endpoint_address
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_iot_policy_attach
  ]
}

# Lambda function for humidity sensor simulation
resource "aws_lambda_function" "humidity_function" {
  function_name    = "humidity_sensor_simulator"
  filename         = data.archive_file.humidity_lambda_zip.output_path
  source_code_hash = data.archive_file.humidity_lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "Humidity.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10

  environment {
    variables = {
      IOT_ENDPOINT = data.aws_iot_endpoint.endpoint.endpoint_address
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_iot_policy_attach
  ]
}

# Lambda function for AQI sensor simulation
resource "aws_lambda_function" "aqi_function" {
  function_name    = "aqi_sensor_simulator"
  filename         = data.archive_file.aqi_lambda_zip.output_path
  source_code_hash = data.archive_file.aqi_lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "AQI.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10

  environment {
    variables = {
      IOT_ENDPOINT = data.aws_iot_endpoint.endpoint.endpoint_address
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_iot_policy_attach
  ]
}

# Lambda function for CO2 sensor simulation
resource "aws_lambda_function" "co2_function" {
  function_name    = "co2_sensor_simulator"
  filename         = data.archive_file.co2_lambda_zip.output_path
  source_code_hash = data.archive_file.co2_lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "Co2.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10

  environment {
    variables = {
      IOT_ENDPOINT = data.aws_iot_endpoint.endpoint.endpoint_address
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_iot_policy_attach
  ]
}

# IAM policy for Lambda to access S3, DynamoDB, SNS and CloudWatch
resource "aws_iam_policy" "s3_dynamo_sns_policy" {
  name        = "lambda_s3_dynamo_sns_policy"
  description = "Allows Lambda functions to read from S3, write to DynamoDB, publish to SNS and publish CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.ecomonitor_raw_data.arn}",
          "${aws_s3_bucket.ecomonitor_raw_data.arn}/*"
        ]
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = "${aws_dynamodb_table.ecomonitor_sensor_data.arn}"
      },
      {
        Action = [
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = "${aws_sns_topic.ecomonitor_errors.arn}"
      },
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "s3_dynamo_sns_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.s3_dynamo_sns_policy.arn
}

# Create ZIP archive for S3 to DynamoDB Lambda
data "archive_file" "s3_to_dynamo_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/data cleaner/s3_to_dynamo.py"
  output_path = "${path.module}/lambda_packages/s3_to_dynamo_function.zip"
}

# Lambda function to process S3 data and save to DynamoDB
resource "aws_lambda_function" "s3_to_dynamo_function" {
  function_name    = "s3_to_dynamo_processor"
  filename         = data.archive_file.s3_to_dynamo_lambda_zip.output_path
  source_code_hash = data.archive_file.s3_to_dynamo_lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "s3_to_dynamo.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60
  memory_size      = 512

  # VPC configuration for private subnet deployment
  vpc_config {
    subnet_ids         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.ecomonitor_sensor_data.name
      SNS_ERROR_TOPIC_ARN = aws_sns_topic.ecomonitor_errors.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.s3_dynamo_sns_policy_attach,
    aws_iam_role_policy_attachment.lambda_vpc_policy_attach
  ]
}

# Permission for S3 to invoke Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_to_dynamo_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ecomonitor_raw_data.arn
}

# CloudWatch Events / EventBridge rule to trigger the temperature lambda function every 5 minutes
resource "aws_cloudwatch_event_rule" "temperature_event_rule" {
  name                = "temperature_sensor_trigger"
  description         = "Triggers the temperature sensor simulator every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "temperature_lambda_target" {
  rule      = aws_cloudwatch_event_rule.temperature_event_rule.name
  target_id = "temperature_lambda"
  arn       = aws_lambda_function.temperature_function.arn
}

resource "aws_lambda_permission" "temperature_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.temperature_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.temperature_event_rule.arn
}

# CloudWatch Events / EventBridge rule to trigger the humidity lambda function every 5 minutes
resource "aws_cloudwatch_event_rule" "humidity_event_rule" {
  name                = "humidity_sensor_trigger"
  description         = "Triggers the humidity sensor simulator every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "humidity_lambda_target" {
  rule      = aws_cloudwatch_event_rule.humidity_event_rule.name
  target_id = "humidity_lambda"
  arn       = aws_lambda_function.humidity_function.arn
}

resource "aws_lambda_permission" "humidity_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.humidity_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.humidity_event_rule.arn
}

# CloudWatch Events / EventBridge rule to trigger the AQI lambda function every 5 minutes
resource "aws_cloudwatch_event_rule" "aqi_event_rule" {
  name                = "aqi_sensor_trigger"
  description         = "Triggers the AQI sensor simulator every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "aqi_lambda_target" {
  rule      = aws_cloudwatch_event_rule.aqi_event_rule.name
  target_id = "aqi_lambda"
  arn       = aws_lambda_function.aqi_function.arn
}

resource "aws_lambda_permission" "aqi_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aqi_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.aqi_event_rule.arn
}

# CloudWatch Events / EventBridge rule to trigger the CO2 lambda function every 5 minutes
resource "aws_cloudwatch_event_rule" "co2_event_rule" {
  name                = "co2_sensor_trigger"
  description         = "Triggers the CO2 sensor simulator every 5 minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "co2_lambda_target" {
  rule      = aws_cloudwatch_event_rule.co2_event_rule.name
  target_id = "co2_lambda"
  arn       = aws_lambda_function.co2_function.arn
}

resource "aws_lambda_permission" "co2_cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.co2_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.co2_event_rule.arn
}

# Security group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_s3_to_dynamo_sg"
  description = "Security group for S3 to DynamoDB Lambda function"
  vpc_id      = aws_vpc.ecomonitor_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EcoMonitor-Lambda-SG"
  }
}

# IAM policy for Lambda VPC execution
resource "aws_iam_policy" "lambda_vpc_policy" {
  name        = "lambda_vpc_execution_policy"
  description = "Allows Lambda functions to create ENIs in VPC"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the VPC policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_vpc_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_vpc_policy.arn
}

# Output the Lambda function ARNs
output "temperature_lambda_arn" {
  value       = aws_lambda_function.temperature_function.arn
  description = "ARN of the temperature sensor simulator Lambda function"
}

output "humidity_lambda_arn" {
  value       = aws_lambda_function.humidity_function.arn
  description = "ARN of the humidity sensor simulator Lambda function"
}

output "aqi_lambda_arn" {
  value       = aws_lambda_function.aqi_function.arn
  description = "ARN of the AQI sensor simulator Lambda function"
}

output "co2_lambda_arn" {
  value       = aws_lambda_function.co2_function.arn
  description = "ARN of the CO2 sensor simulator Lambda function"
}