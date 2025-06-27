# CloudWatch Dashboard for EcoMonitor Data Transfer Visualization

# CloudWatch Dashboard for monitoring S3 to DynamoDB data transfer
resource "aws_cloudwatch_dashboard" "ecomonitor_dashboard" {
  dashboard_name = "EcoMonitor-Data-Pipeline"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.s3_to_dynamo_function.function_name],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "S3 to DynamoDB Lambda Function Metrics"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", aws_dynamodb_table.ecomonitor_sensor_data.name],
            [".", "ConsumedReadCapacityUnits", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "DynamoDB Capacity Consumption"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/S3", "NumberOfObjects", "BucketName", aws_s3_bucket.ecomonitor_raw_data.bucket, "StorageType", "AllStorageTypes"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "S3 Object Count"
          period  = 300
          stat    = "Average"
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 6
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/S3", "BucketSizeBytes", "BucketName", aws_s3_bucket.ecomonitor_raw_data.bucket, "StorageType", "StandardStorage"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "S3 Bucket Size"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 6
        width  = 8
        height = 6

        properties = {
          metrics = [
            ["AWS/DynamoDB", "ItemCount", "TableName", aws_dynamodb_table.ecomonitor_sensor_data.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "DynamoDB Item Count"
          period  = 300
          stat    = "Average"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6

        properties = {
          query   = "SOURCE '/aws/lambda/${aws_lambda_function.s3_to_dynamo_function.function_name}'\n| fields @timestamp, @message\n| filter @message like /Successfully processed/\n| sort @timestamp desc\n| limit 20"
          region  = "us-east-1"
          title   = "Recent Successful Data Transfers"
          view    = "table"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", aws_lambda_function.temperature_function.function_name],
            [".", ".", ".", aws_lambda_function.humidity_function.function_name],
            [".", ".", ".", aws_lambda_function.aqi_function.function_name],
            [".", ".", ".", aws_lambda_function.co2_function.function_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "IoT Sensor Simulator Invocations"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", aws_lambda_function.s3_to_dynamo_function.function_name],
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", aws_dynamodb_table.ecomonitor_sensor_data.name, "Operation", "PutItem"]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "Error Metrics"
          period  = 300
          stat    = "Sum"
        }
      },
      {
        type   = "text"
        x      = 0
        y      = 24
        width  = 24
        height = 2

        properties = {
          markdown = "## EcoMonitor Data Pipeline Overview\n\nThis dashboard monitors the complete data flow from IoT sensor simulators → S3 → Lambda → DynamoDB. \n\n**Key Metrics:**\n- **Lambda Invocations**: Tracks how many times the S3-to-DynamoDB processor runs\n- **DynamoDB Writes**: Shows data being written to the database\n- **Error Monitoring**: Identifies any issues in the pipeline\n- **Storage Metrics**: Monitors S3 bucket growth and DynamoDB item count"
        }
      }
    ]
  })
}

# CloudWatch Log Group for the S3 to DynamoDB Lambda function
resource "aws_cloudwatch_log_group" "s3_to_dynamo_logs" {
  name              = "/aws/lambda/${aws_lambda_function.s3_to_dynamo_function.function_name}"
  retention_in_days = 14

  tags = {
    Name = "EcoMonitor-S3-DynamoDB-Logs"
  }
}

# CloudWatch Log Groups for IoT sensor simulators
resource "aws_cloudwatch_log_group" "temperature_logs" {
  name              = "/aws/lambda/${aws_lambda_function.temperature_function.function_name}"
  retention_in_days = 7

  tags = {
    Name = "EcoMonitor-Temperature-Logs"
  }
}

resource "aws_cloudwatch_log_group" "humidity_logs" {
  name              = "/aws/lambda/${aws_lambda_function.humidity_function.function_name}"
  retention_in_days = 7

  tags = {
    Name = "EcoMonitor-Humidity-Logs"
  }
}

resource "aws_cloudwatch_log_group" "aqi_logs" {
  name              = "/aws/lambda/${aws_lambda_function.aqi_function.function_name}"
  retention_in_days = 7

  tags = {
    Name = "EcoMonitor-AQI-Logs"
  }
}

resource "aws_cloudwatch_log_group" "co2_logs" {
  name              = "/aws/lambda/${aws_lambda_function.co2_function.function_name}"
  retention_in_days = 7

  tags = {
    Name = "EcoMonitor-CO2-Logs"
  }
}

# CloudWatch Alarms for monitoring the data pipeline
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "ecomonitor-s3-dynamo-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors lambda errors in S3 to DynamoDB processor"
  alarm_actions       = [aws_sns_topic.ecomonitor_errors.arn]

  dimensions = {
    FunctionName = aws_lambda_function.s3_to_dynamo_function.function_name
  }

  tags = {
    Name = "EcoMonitor-Lambda-Errors"
  }
}

resource "aws_cloudwatch_metric_alarm" "dynamo_throttles" {
  alarm_name          = "ecomonitor-dynamo-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors DynamoDB throttling"
  alarm_actions       = [aws_sns_topic.ecomonitor_errors.arn]

  dimensions = {
    TableName = aws_dynamodb_table.ecomonitor_sensor_data.name
    Operation = "PutItem"
  }

  tags = {
    Name = "EcoMonitor-DynamoDB-Throttles"
  }
}

# Custom CloudWatch Metrics for data pipeline monitoring
resource "aws_cloudwatch_log_metric_filter" "successful_transfers" {
  name           = "SuccessfulDataTransfers"
  log_group_name = aws_cloudwatch_log_group.s3_to_dynamo_logs.name
  pattern        = "Data successfully saved to DynamoDB"

  metric_transformation {
    name      = "SuccessfulTransfers"
    namespace = "EcoMonitor/DataPipeline"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "failed_transfers" {
  name           = "FailedDataTransfers"
  log_group_name = aws_cloudwatch_log_group.s3_to_dynamo_logs.name
  pattern        = "Error processing S3 file"

  metric_transformation {
    name      = "FailedTransfers"
    namespace = "EcoMonitor/DataPipeline"
    value     = "1"
  }
}

# Output the dashboard URL
output "cloudwatch_dashboard_url" {
  value = "https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${aws_cloudwatch_dashboard.ecomonitor_dashboard.dashboard_name}"
  description = "URL to access the EcoMonitor CloudWatch Dashboard"
}
