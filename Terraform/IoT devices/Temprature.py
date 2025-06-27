import json
import random
import boto3
import logging
import os
import datetime

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize CloudWatch client
cloudwatch = boto3.client('cloudwatch')

def put_sensor_metric(metric_name, value, unit='None', dimensions=None):
    """Publish custom metrics to CloudWatch for enhanced dashboard visuals"""
    try:
        cloudwatch.put_metric_data(
            Namespace='EcoMonitor/SensorData',
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': unit,
                    'Timestamp': datetime.datetime.utcnow(),
                    'Dimensions': dimensions or [
                        {
                            'Name': 'SensorType',
                            'Value': 'Temperature'
                        },
                        {
                            'Name': 'DeviceId',
                            'Value': 'temp_sensor_01'
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
    
    # Generate random temperature data (in Celsius)
    temperature = round(random.uniform(18.0, 35.0), 1)
    
    # Determine temperature category and health status
    if temperature < 18:
        category = "Very Cold"
        health_status = "Alert"
        alert_count = 1
        good_conditions = 0
        unhealthy_conditions = 1
    elif temperature < 20:
        category = "Cold"
        health_status = "Moderate"
        alert_count = 0
        good_conditions = 0
        unhealthy_conditions = 0
    elif temperature <= 28:
        category = "Optimal"
        health_status = "Good"
        alert_count = 0
        good_conditions = 1
        unhealthy_conditions = 0
    elif temperature <= 35:
        category = "Warm"
        health_status = "Moderate"
        alert_count = 0
        good_conditions = 0
        unhealthy_conditions = 0
    else:
        category = "Very Hot"
        health_status = "Alert"
        alert_count = 1
        good_conditions = 0
        unhealthy_conditions = 1
    
    # Create the enhanced payload
    payload = {
        'device_id': 'temp_sensor_01',
        'temperature': temperature,
        'unit': 'Celsius',
        'category': category,
        'health_status': health_status,
        'timestamp': context.aws_request_id,
        'reading_time': datetime.datetime.utcnow().isoformat(),
        'location': 'EcoMonitor_Zone_A'
    }
    
    # Enhanced logging with visual indicators
    logger.info(f"🌡️ [TEMPERATURE SENSOR] Temperature sensor data: {json.dumps(payload)}")
    logger.info(f"📊 [METRICS] Temp: {temperature}°C | Category: {category} | Health: {health_status}")
    
    # Put comprehensive metrics to CloudWatch for enhanced visuals
    put_sensor_metric('TemperatureReading', temperature, 'None')
    put_sensor_metric('SensorActivity', 1, 'Count')
    
    # Health category metrics for stacked charts
    put_sensor_metric('GoodConditions', good_conditions, 'Count', [
        {'Name': 'HealthCategory', 'Value': 'Good'},
        {'Name': 'SensorType', 'Value': 'Temperature'}
    ])
    put_sensor_metric('ModerateConditions', 1 if health_status == 'Moderate' else 0, 'Count', [
        {'Name': 'HealthCategory', 'Value': 'Moderate'},
        {'Name': 'SensorType', 'Value': 'Temperature'}
    ])
    put_sensor_metric('UnhealthyConditions', unhealthy_conditions, 'Count', [
        {'Name': 'HealthCategory', 'Value': 'Unhealthy'},
        {'Name': 'SensorType', 'Value': 'Temperature'}
    ])
    
    # Alert metrics for monitoring
    put_sensor_metric('TemperatureAlert', alert_count, 'Count', [
        {'Name': 'AlertType', 'Value': 'Temperature'},
        {'Name': 'DeviceId', 'Value': 'temp_sensor_01'}
    ])
    
    # Category-specific metrics for visualization
    if temperature < 18 or temperature > 35:
        put_sensor_metric('CriticalTemperature', 1, 'Count')
    
    # Publish to IoT Core topic
    try:
        client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
        
        response = client.publish(
            topic='sensor/temperature',
            qos=1,
            payload=json.dumps(payload)
        )
        
        logger.info(f"✅ [SUCCESS] Published temperature data to IoT Core: {response}")
        
    except Exception as e:
        logger.error(f"❌ [ERROR] Failed to publish to IoT Core: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Temperature sensor data processed successfully',
            'temperature': temperature,
            'category': category,
            'health_status': health_status,
            'timestamp': payload['reading_time']
        })
    }
