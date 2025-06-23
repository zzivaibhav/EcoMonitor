import boto3
import json
import random
import time
import os

IOT_ENDPOINT = os.environ['IOT_ENDPOINT']

def lambda_handler(event, context):
    value = round(random.uniform(20.0, 27.0), 2)
    payload = {
        "device_id": "temp-001",
        "type": "temperature",
        "timestamp": int(time.time()),
        "value": value
    }
    topic = "sensors/temperature"
    iot_client = boto3.client('iot-data', endpoint_url=f"https://{IOT_ENDPOINT}")
    iot_client.publish(topic=topic, qos=0, payload=json.dumps(payload))
    return {'statusCode': 200, 'body': json.dumps({'published': payload})}
