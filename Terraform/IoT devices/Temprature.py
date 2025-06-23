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
    
    # Generate random temperature data (in Celsius)
    temperature = round(random.uniform(18.0, 35.0), 1)
    
    # Create the payload
    payload = {
        'device_id': 'temp_sensor_01',
        'temperature': temperature,
        'unit': 'Celsius',
        'timestamp': context.aws_request_id
    }
    
    # Log the sensor data
    logger.info(f"Temperature sensor data: {json.dumps(payload)}")
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/temperature',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Temperature data published successfully')
    }
