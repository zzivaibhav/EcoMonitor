import boto3
import json
import random
import time
import os

IOT_ENDPOINT = os.environ['IOT_ENDPOINT']

def lambda_handler(event, context):
    value = random.randint(0, 150)
    payload = {
        "device_id": "aqi-001",
        "type": "aqi",
        "timestamp": int(time.time()),
        "value": value
    }
    topic = "sensors/aqi"
    iot_client = boto3.client('iot-data', endpoint_url=f"https://{IOT_ENDPOINT}")
    iot_client.publish(topic=topic, qos=0, payload=json.dumps(payload))
    return {'statusCode': 200, 'body': json.dumps({'published': payload})}
