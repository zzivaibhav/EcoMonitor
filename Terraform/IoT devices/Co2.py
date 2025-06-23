import boto3
import json
import random
import time
import os

IOT_ENDPOINT = os.environ['IOT_ENDPOINT']

def lambda_handler(event, context):
    value = random.randint(400, 1200)
    payload = {
        "device_id": "co2-001",
        "type": "co2",
        "timestamp": int(time.time()),
        "value": value
    }
    topic = "sensors/co2"
    iot_client = boto3.client('iot-data', endpoint_url=f"https://{IOT_ENDPOINT}")
    iot_client.publish(topic=topic, qos=0, payload=json.dumps(payload))
    return {'statusCode': 200, 'body': json.dumps({'published': payload})}
