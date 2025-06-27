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
                            'Value': 'CO2'
                        },
                        {
                            'Name': 'DeviceId',
                            'Value': 'co2_sensor_01'
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
    
    # Generate random CO2 data (in ppm)
    co2_level = round(random.uniform(300.0, 1500.0), 1)
    
    # Determine CO2 level category with more detailed breakdown
    if co2_level < 400:
        category = "Excellent"
        health_impact = "Fresh outdoor air level"
    elif co2_level < 600:
        category = "Good"
        health_impact = "Acceptable indoor air quality"
    elif co2_level < 1000:
        category = "Acceptable"
        health_impact = "Drowsiness may occur"
    elif co2_level < 1500:
        category = "High"
        health_impact = "Stuffy air, poor concentration"
    else:
        category = "Very High"
        health_impact = "Immediate ventilation required"
    
    # Create the payload
    payload = {
        'device_id': 'co2_sensor_01',
        'co2': co2_level,
        'unit': 'ppm',
        'category': category,
        'health_impact': health_impact,
        'timestamp': context.aws_request_id,
        'reading_time': datetime.datetime.utcnow().isoformat()
    }
    
    # Log the sensor data with enhanced formatting
    logger.info(f"🫁 [CO2 SENSOR] CO2 sensor data: {json.dumps(payload)}")
    
    # Put custom metrics to CloudWatch
    put_sensor_metric('CO2Reading', co2_level, 'None')
    put_sensor_metric('CO2SensorActive', 1, 'Count')
    
    # Category-specific metrics
    if category in ["High", "Very High"]:
        put_sensor_metric('HighCO2Alert', 1, 'Count')
    elif category == "Excellent":
        put_sensor_metric('ExcellentAirQuality', 1, 'Count')
    
    # Publish to IoT Core topic
    client = boto3.client('iot-data', endpoint_url=f'https://{iot_endpoint}')
    
    response = client.publish(
        topic='eco/sensors/co2',
        qos=1,
        payload=json.dumps(payload)
    )
    
    # Log the response
    logger.info(f"✅ [IOT PUBLISH] IoT publish response: {response}")
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'CO2 data published successfully',
            'co2': co2_level,
            'category': category
        })
    }
