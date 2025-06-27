import json
import random
import boto3
import logging
import os
import datetime

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def put_sensor_metric(metric_name, value, unit='None'):
    """Put custom metric to CloudWatch for sensor data"""
    try:
        cloudwatch = boto3.client('cloudwatch')
        cloudwatch.put_metric_data(
            Namespace='EcoMonitor/SensorData',
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit,
                    'Timestamp': datetime.datetime.utcnow(),
                    'Dimensions': [
                        {
                            'Name': 'SensorType',
                            'Value': 'Humidity'
                        },
                        {
                            'Name': 'DeviceId',
                            'Value': 'humidity_sensor_01'
                        }
                    ]
                },
            ]
        )
    except Exception as e:
        logger.error(f"Failed to put metric {metric_name}: {str(e)}")

def lambda_handler(event, context):
    # Get the IoT endpoint from environment variables
    iot_endpoint = os.environ.get('IOT_ENDPOINT')
    
    # Generate random humidity data (in percentage)
    humidity = round(random.uniform(30.0, 90.0), 1)
    
    # Determine humidity category
    if humidity < 40:
        category = "Low"
    elif humidity < 60:
        category = "Optimal"
    elif humidity < 75:
        category = "High"
    else:
        category = "Very High"
    
    # Create the payload
    payload = {
        'device_id': 'humidity_sensor_01',
        'humidity': humidity,
        'unit': 'percentage',
        'category': category,
        'timestamp': context.aws_request_id,
        'reading_time': datetime.datetime.utcnow().isoformat()
    }
    
    # Log the sensor data with enhanced formatting
    logger.info(f"💧 [HUMIDITY SENSOR] Humidity sensor data: {json.dumps(payload)}")
    
    # Put custom metrics to CloudWatch
    put_sensor_metric('HumidityReading', humidity, 'Percent')
    put_sensor_metric('HumiditySensorActive', 1, 'Count')
    
    # Category-specific metrics
    if category == "Very High":
        put_sensor_metric('HighHumidityAlert', 1, 'Count')
    elif category == "Low":
        put_sensor_metric('LowHumidityAlert', 1, 'Count')
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/humidity',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"✅ [IOT PUBLISH] IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Humidity data published successfully',
            'humidity': humidity,
            'category': category
        })
    }
