import json
import random
import boto3
import logging
import os

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Get the IoT endpoint from environment variables
    iot_endpoint = os.environ.get('IOT_ENDPOINT')
    
    # Generate random AQI data
    aqi = round(random.uniform(10.0, 150.0), 1)
    
    # Determine air quality category
    category = "Good"
    if aqi > 100:
        category = "Unhealthy"
    elif aqi > 50:
        category = "Moderate"
    
    # Create the payload
    payload = {
        'device_id': 'aqi_sensor_01',
        'aqi': aqi,
        'category': category,
        'timestamp': context.aws_request_id
    }
    
    # Log the sensor data
    logger.info(f"AQI sensor data: {json.dumps(payload)}")
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/aqi',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('AQI data published successfully')
    }
