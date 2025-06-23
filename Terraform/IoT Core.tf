# AWS IoT Core Configuration

# Create an IoT Thing Type for environmental sensors
resource "aws_iot_thing_type" "eco_sensor" {
  name        = "eco_sensor"

  properties {
    searchable_attributes = ["location", "sensor_type"]
  }
}

# Create IoT Things for each sensor type
resource "aws_iot_thing" "temperature_sensor" {
  name = "temp-001"
  thing_type_name = aws_iot_thing_type.eco_sensor.name
  
  attributes = {
    sensor_type = "temperature"
    location    = "facility-main"
  }
}

resource "aws_iot_thing" "humidity_sensor" {
  name = "humidity-001"
  thing_type_name = aws_iot_thing_type.eco_sensor.name
  
  attributes = {
    sensor_type = "humidity"
    location    = "facility-main"
  }
}

resource "aws_iot_thing" "aqi_sensor" {
  name = "aqi-001"
  thing_type_name = aws_iot_thing_type.eco_sensor.name
  
  attributes = {
    sensor_type = "aqi"
    location    = "facility-main"
  }
}

resource "aws_iot_thing" "co2_sensor" {
  name = "co2-001"
  thing_type_name = aws_iot_thing_type.eco_sensor.name
  
  attributes = {
    sensor_type = "co2"
    location    = "facility-main"
  }
}

# Create certificates for authentication
resource "aws_iot_certificate" "cert" {
  active = true
}

# Policy to allow publishing to specific topics
resource "aws_iot_policy" "sensor_policy" {
  name = "ecomonitor-sensor-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "iot:Connect",
          "iot:Publish"
        ]
        Resource = [
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.temperature_sensor.name}",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.humidity_sensor.name}",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.aqi_sensor.name}",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.co2_sensor.name}",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/sensors/temperature",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/sensors/humidity",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/sensors/aqi",
          "arn:aws:iot:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:topic/sensors/co2"
        ]
      }
    ]
  })
}

# Attach policy to certificate
resource "aws_iot_policy_attachment" "sensor_policy_attachment" {
  policy = aws_iot_policy.sensor_policy.name
  target = aws_iot_certificate.cert.arn
}

# Attach certificates to things
resource "aws_iot_thing_principal_attachment" "temperature_cert_attach" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.temperature_sensor.name
}

resource "aws_iot_thing_principal_attachment" "humidity_cert_attach" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.humidity_sensor.name
}

resource "aws_iot_thing_principal_attachment" "aqi_cert_attach" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.aqi_sensor.name
}

resource "aws_iot_thing_principal_attachment" "co2_cert_attach" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.co2_sensor.name
}

# IoT Rule to route temperature data to CloudWatch and S3
resource "aws_iot_topic_rule" "temperature_rule" {
  name        = "temperature_data_rule"
  description = "Rule for processing temperature sensor data"
  enabled     = true
  sql         = "SELECT * FROM 'sensors/temperature'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.sensor_logs.name
    role_arn       = aws_iam_role.iot_role.arn
  }
  
  s3 {
    bucket_name = aws_s3_bucket.ecomonitor_raw_data.bucket
    key         = "$${topic()}/data.json"
    role_arn    = aws_iam_role.iot_role.arn
  }
}

# Similar rules for other sensor types
resource "aws_iot_topic_rule" "humidity_rule" {
  name        = "humidity_data_rule"
  description = "Rule for processing humidity sensor data"
  enabled     = true
  sql         = "SELECT * FROM 'sensors/humidity'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.sensor_logs.name
    role_arn       = aws_iam_role.iot_role.arn
  }
  
  s3 {
    bucket_name = aws_s3_bucket.ecomonitor_raw_data.bucket
    key         = "$${topic()}/data.json"
    role_arn    = aws_iam_role.iot_role.arn
  }
}

resource "aws_iot_topic_rule" "aqi_rule" {
  name        = "aqi_data_rule"
  description = "Rule for processing air quality sensor data"
  enabled     = true
  sql         = "SELECT * FROM 'sensors/aqi'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.sensor_logs.name
    role_arn       = aws_iam_role.iot_role.arn
  }
  
  s3 {
    bucket_name = aws_s3_bucket.ecomonitor_raw_data.bucket
    key         = "$${topic()}/data.json"
    role_arn    = aws_iam_role.iot_role.arn
  }
}

resource "aws_iot_topic_rule" "co2_rule" {
  name        = "co2_data_rule"
  description = "Rule for processing CO2 sensor data"
  enabled     = true
  sql         = "SELECT * FROM 'sensors/co2'"
  sql_version = "2016-03-23"

  cloudwatch_logs {
    log_group_name = aws_cloudwatch_log_group.sensor_logs.name
    role_arn       = aws_iam_role.iot_role.arn
  }
  
  s3 {
    bucket_name = aws_s3_bucket.ecomonitor_raw_data.bucket
    key         = "$${topic()}/data.json"
    role_arn    = aws_iam_role.iot_role.arn
  }
}

# IoT Rule to route ALL sensor data to S3 for archival
resource "aws_iot_topic_rule" "all_sensors_s3_rule" {
  name        = "all_sensors_s3_rule"
  description = "Rule for storing all sensor data in S3 as-is"
  enabled     = true
  sql         = "SELECT * FROM 'sensors/#'"
  sql_version = "2016-03-23"
  
  s3 {
    bucket_name = aws_s3_bucket.ecomonitor_raw_data.bucket
    key         = "raw-data/$${topic()}.json"
    role_arn    = aws_iam_role.iot_role.arn
  }
}

# CloudWatch Log Group for IoT data
resource "aws_cloudwatch_log_group" "sensor_logs" {
  name = "/aws/iot/ecomonitor/sensors"
  retention_in_days = 30
  
  tags = {
    Project = "EcoMonitor"
    Service = "IoT"
  }
}

# IAM Role for IoT to write to CloudWatch
resource "aws_iam_role" "iot_role" {
  name = "iot-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "iot_logging_policy" {
  name = "iot-logging-policy"
  role = aws_iam_role.iot_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.sensor_logs.arn}:*"
      },
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "${aws_s3_bucket.ecomonitor_raw_data.arn}",
          "${aws_s3_bucket.ecomonitor_raw_data.arn}/*"
        ]
      }
    ]
  })
}

# Get current region and account ID for ARN construction
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Output the IoT endpoint to use in the applications
output "iot_endpoint" {
  value = data.aws_iot_endpoint.endpoint.endpoint_address
  description = "IoT endpoint for device connection"
}

# Get the IoT endpoint
data "aws_iot_endpoint" "endpoint" {
  endpoint_type = "iot:Data-ATS"
}