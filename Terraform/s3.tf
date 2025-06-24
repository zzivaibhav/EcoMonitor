# S3 bucket configuration for storing EcoMonitor raw data
resource "aws_s3_bucket" "ecomonitor_raw_data" {
  bucket = "ecomonitor-raw-b01006432"
  force_destroy = true  # This allows Terraform to destroy a bucket with content

  tags = {
    Name        = "EcoMonitor Raw Data"
    Description = "Stores raw data from IoT sensors"
  }
}

# Configure bucket versioning - enabling versioning helps protect against accidental deletions
resource "aws_s3_bucket_versioning" "ecomonitor_versioning" {
  bucket = aws_s3_bucket.ecomonitor_raw_data.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "ecomonitor_encryption" {
  bucket = aws_s3_bucket.ecomonitor_raw_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Configure lifecycle rules for the bucket
resource "aws_s3_bucket_lifecycle_configuration" "ecomonitor_lifecycle" {
  bucket = aws_s3_bucket.ecomonitor_raw_data.id

  rule {
    id     = "archive-after-90-days"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}

# Block public access to the bucket for security
resource "aws_s3_bucket_public_access_block" "ecomonitor_access_block" {
  bucket = aws_s3_bucket.ecomonitor_raw_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configure S3 bucket to notify Lambda when objects are created
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.ecomonitor_raw_data.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_to_dynamo_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "sensors/"
    filter_suffix       = ".json"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}


