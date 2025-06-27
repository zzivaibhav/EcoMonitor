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
                            'Value': 'AQI'
                        },
                        {
                            'Name': 'DeviceId',
                            'Value': 'aqi_sensor_01'
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
    
    # Generate random AQI data
    aqi = round(random.uniform(10.0, 150.0), 1)
    
    # Determine air quality category
    if aqi <= 50:
        category = "Good"
        health_concern = "Minimal"
    elif aqi <= 100:
        category = "Moderate"
        health_concern = "Acceptable"
    elif aqi <= 150:
        category = "Unhealthy for Sensitive Groups"
        health_concern = "Sensitive people may experience problems"
    else:
        category = "Unhealthy"
        health_concern = "Everyone may experience problems"
    
    # Create the payload
    payload = {
        'device_id': 'aqi_sensor_01',
        'aqi': aqi,
        'category': category,
        'health_concern': health_concern,
        'timestamp': context.aws_request_id,
        'reading_time': datetime.datetime.utcnow().isoformat()
    }
    
    # Log the sensor data with enhanced formatting
    logger.info(f"🏭 [AQI SENSOR] AQI sensor data: {json.dumps(payload)}")
    
    # Put custom metrics to CloudWatch
    put_sensor_metric('AQIReading', aqi, 'None')
    put_sensor_metric('AQISensorActive', 1, 'Count')
    
    # Category-specific metrics
    if category == "Unhealthy" or aqi > 100:
        put_sensor_metric('UnhealthyAirAlert', 1, 'Count')
    elif category == "Good":
        put_sensor_metric('GoodAirQuality', 1, 'Count')
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/aqi',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"✅ [IOT PUBLISH] IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'AQI data published successfully',
            'aqi': aqi,
            'category': category
        })
    }
