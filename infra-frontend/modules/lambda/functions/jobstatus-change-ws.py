import json
import urllib3
import boto3
import base64
from boto3.dynamodb.types import TypeDeserializer
from decimal import Decimal

# Initialize HTTP client
http = urllib3.PoolManager()

# AWS Secrets Manager details
SECRET_NAME = "pw-scheduler-dispatcher-dev-secret"
DOMAIN_KEY = "lambda_websocket_domain_api_url"
REGION_NAME = "us-east-1"  # update if your secret is in a different region
CREDENTIALS_USER_KEY = "lambda_websocket_user"
CREDENTIALS_PASSWORD_KEY = "lambda_websocket_pwd"

# Fetch the secret value from AWS Secrets Manager
def get_secret_value(secret_name, key):
    client = boto3.client("secretsmanager", region_name=REGION_NAME)
    secret_response = client.get_secret_value(SecretId=secret_name)
    secret_string = secret_response.get("SecretString")
    if secret_string:
        secret_dict = json.loads(secret_string)
        return secret_dict.get(key)
    return None

# Fetch domain from secret manager
domain = get_secret_value(SECRET_NAME, DOMAIN_KEY)
user = get_secret_value(SECRET_NAME, CREDENTIALS_USER_KEY)
pwd = get_secret_value(SECRET_NAME, CREDENTIALS_PASSWORD_KEY)
if not domain:
    raise Exception(f"❌ Could not fetch domain from secret: {SECRET_NAME} with key: {DOMAIN_KEY}")
if not user:
    raise Exception(f"❌ Could not fetch user from secret: {SECRET_NAME} with key: {CREDENTIALS_USER_KEY}")
if not pwd:
    raise Exception(f"❌ Could not fetch password from secret: {SECRET_NAME} with key: {CREDENTIALS_PASSWORD_KEY}")

path = "/scheduler/websocket/jobUpdate"
BACKEND_URL = domain + path

print(f"✅ Domain from Secrets Manager: {domain}")
print(f"✅ Backend URL: {BACKEND_URL}")

# For deserializing DynamoDB stream format into native Python types
deserializer = TypeDeserializer()

def convert_for_json(obj):
    if isinstance(obj, list) or isinstance(obj, tuple):
        return [convert_for_json(item) for item in obj]
    elif isinstance(obj, dict):
        return {key: convert_for_json(val) for key, val in obj.items()}
    elif isinstance(obj, set):
        return list(obj)
    elif isinstance(obj, Decimal):
        return int(obj) if obj % 1 == 0 else float(obj)
    elif isinstance(obj, bytes):
        return base64.b64encode(obj).decode('utf-8')
    else:
        return obj

def lambda_handler(event, context):
    response_data = []
    try:
        for record in event['Records']:
            print("✅ Triggering pw-lambda-dev-jobstatus-change-ws lambda")
            if record['eventName'] not in ['INSERT', 'MODIFY', 'DELETE']:
                print(f"ℹ️ Skipping event type: {record['eventName']}")
                continue

            print(f"✅ Captured event: {record['eventName']}")
            new_image = record['dynamodb'].get('NewImage', {})
            old_image = record['dynamodb'].get('OldImage', {})

            record_response = {
                'eventName': record['eventName'],
                'eventID': record.get('eventID'),
            }

            if new_image:
                raw_new = {k: deserializer.deserialize(v) for k, v in new_image.items()}
                new_job = convert_for_json(raw_new)
                record_response['newImage'] = new_job

            if old_image:
                raw_old = {k: deserializer.deserialize(v) for k, v in old_image.items()}
                old_job = convert_for_json(raw_old)
                record_response['oldImage'] = old_job

            if new_image:
                try:
                    payload = json.dumps(new_job).encode('utf-8')
                    headers = {
                        "Content-Type": "application/json",
                        "username": user,
                        "password": pwd
                    }
                    print(f"Request headers : {headers} | Payload: {payload.decode('utf-8')}")

                    resp = http.request(
                        "POST",
                        BACKEND_URL,
                        body=payload,
                        headers=headers
                    )
                    body = resp.data.decode('utf-8')
                    try:
                        parsed_body = json.loads(body) if body else None
                    except json.JSONDecodeError:
                        parsed_body = body

                    record_response['backendResponse'] = {
                        'status': resp.status,
                        'body': parsed_body
                    }

                    print(f"✅ Sent job update: {new_job} | Response: {resp.status} | Body: {parsed_body}")
                except Exception as e:
                    record_response['error'] = str(e)
                    print(f"❌ Error sending job update: {e}")

            response_data.append(record_response)

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Processing complete',
                'recordsProcessed': len(response_data),
                'details': response_data
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({
                'message': 'Error processing records',
                'error': str(e),
                'recordsProcessed': len(response_data),
                'details': response_data
            })
        }
