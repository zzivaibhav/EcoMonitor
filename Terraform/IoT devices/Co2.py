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
    
    # Generate random CO2 data (in ppm)
    co2_level = round(random.uniform(300.0, 1500.0), 1)
    
    # Determine CO2 level category
    if co2_level < 600:
        category = "Good"
    elif co2_level < 1000:
        category = "Acceptable"
    else:
        category = "High"
    
    # Create the payload
    payload = {
        'device_id': 'co2_sensor_01',
        'co2': co2_level,
        'unit': 'ppm',
        'category': category,
        'timestamp': context.aws_request_id
    }
    
    # Log the sensor data
    logger.info(f"CO2 sensor data: {json.dumps(payload)}")
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/co2',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('CO2 data published successfully')
    }
