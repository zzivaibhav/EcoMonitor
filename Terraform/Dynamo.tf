resource "aws_dynamodb_table" "ecomonitor_sensor_data" {
  name           = "ecomonitor_processed_data"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "device_id"
  range_key      = "timestamp"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "reading_date"
    type = "S"
  }

  ttl {
    attribute_name = "expiry_time"
    enabled        = true
  }

  global_secondary_index {
    name               = "DateIndex"
    hash_key           = "reading_date"
    range_key          = "timestamp"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "ALL"
  }

  tags = {
    Name        = "ecomonitor-sensor-data"
    Environment = "production"
    Project     = "EcoMonitor"
  }
}