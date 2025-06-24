import json
import boto3
import os
import uuid
import datetime
import urllib.parse
from decimal import Decimal
import logging

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

# Get environment variables
TABLE_NAME = os.environ.get('DYNAMODB_TABLE_NAME')
ERROR_TOPIC_ARN = os.environ.get('SNS_ERROR_TOPIC_ARN')

def lambda_handler(event, context):
    try:
        # Log the entire event for debugging
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Get bucket name and file key from the event
        bucket = event['Records'][0]['s3']['bucket']['name']
        key = event['Records'][0]['s3']['object']['key']
        
        # URL decode the key (S3 keys can be URL encoded in events)
        key = urllib.parse.unquote_plus(key)
        
        logger.info(f"Processing file: {key} from bucket: {bucket}")
        
        try:
            # Get the file content from S3
            response = s3_client.get_object(Bucket=bucket, Key=key)
            file_content = response['Body'].read().decode('utf-8')
            logger.info(f"Successfully read file content: {file_content[:200]}...")  # Log first 200 chars
            
            # Parse JSON content
            try:
                sensor_data = json.loads(file_content, parse_float=Decimal)
            except json.JSONDecodeError as je:
                logger.error(f"Error parsing JSON: {str(je)}. Raw content: {file_content}")
                raise
                
            # Determine sensor type from the file path/name
            sensor_type = None
            if 'temperature' in key.lower():
                sensor_type = 'temperature'
            elif 'humidity' in key.lower():
                sensor_type = 'humidity'
            elif 'aqi' in key.lower():
                sensor_type = 'aqi'
            elif 'co2' in key.lower():
                sensor_type = 'co2'
            else:
                sensor_type = 'unknown'
            
            # Ensure we have a device_id
            if 'device_id' not in sensor_data:
                # Extract device_id from the path if possible, or use a default
                path_parts = key.split('/')
                if len(path_parts) >= 2:
                    sensor_data['device_id'] = f"{sensor_type}_sensor_{path_parts[-2]}"
                else:
                    sensor_data['device_id'] = f"{sensor_type}_sensor_default"
            
            # Get existing data or create new item structure
            table = dynamodb.Table(TABLE_NAME)
            
            # Generate a timestamp if not present
            if 'timestamp' not in sensor_data:
                sensor_data['timestamp'] = context.aws_request_id
            
            # Add reading_date for the GSI - extract date from timestamp or use current date
            current_date = datetime.datetime.now().strftime('%Y-%m-%d')
            sensor_data['reading_date'] = current_date
            
            # Add sensor_type if not already included
            if 'sensor_type' not in sensor_data:
                sensor_data['sensor_type'] = sensor_type
            
            # Put item in DynamoDB
            response = table.put_item(Item=sensor_data)
            
            logger.info(f"Data saved to DynamoDB: {json.dumps(sensor_data, default=str)}")
            return {
                'statusCode': 200,
                'body': json.dumps(f"Successfully processed {key}")
            }
            
        except s3_client.exceptions.NoSuchKey:
            error_message = f"The object key {key} does not exist in bucket {bucket}. It may have been deleted."
            logger.error(error_message)
            if ERROR_TOPIC_ARN:
                sns_client.publish(
                    TopicArn=ERROR_TOPIC_ARN,
                    Subject=f"EcoMonitor S3 Missing Key Error",
                    Message=error_message
                )
            return {
                'statusCode': 404,
                'body': json.dumps(f"Error: File not found - {key}")
            }
    
    except Exception as e:
        error_message = f"Error processing S3 file {bucket}/{key}: {str(e)}"
        logger.error(error_message)
        
        # Send error notification to SNS
        try:
            if ERROR_TOPIC_ARN:
                sns_client.publish(
                    TopicArn=ERROR_TOPIC_ARN,
                    Subject=f"EcoMonitor S3 Processing Error",
                    Message=error_message
                )
        except Exception as sns_error:
            logger.error(f"Failed to publish error to SNS: {str(sns_error)}")
        
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing file: {str(e)}")
        }
