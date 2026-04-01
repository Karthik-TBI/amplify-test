import boto3
import http.client
import urllib.parse
import time
import tempfile
import os

devicefarm = boto3.client('devicefarm', region_name='us-west-2')
s3 = boto3.client('s3')

def start_test(bucket_name, key_name, project_arn, devicepool_arn):
    # Get temp directory path
    tmp_dir = tempfile.mkdtemp()

    # Get input artifact
    input_file = tmp_dir + "/" + key_name

    obj = s3.get_object(
    Bucket=bucket_name,
    Key=key_name
    )

    input_bytes = obj['Body'].read()
    f = open(input_file, 'wb')
    f.write(input_bytes)
    f.close()

    # Read APK bytes
    f = open(input_file, 'rb')
    apk_bytes = f.read()
    f.close()

    # Create upload in DeviceFarm
    resp = devicefarm.create_upload(
    projectArn=project_arn,
    name=key_name,
    type='ANDROID_APP',
    contentType='application/octet-stream'
    )

    upload_url = resp['upload']['url']
    upload_arn = resp['upload']['arn']

    # Set HTTP request headers
    headers = {
    "Content-type": "application/octet-stream",
    "Content-length": len(apk_bytes)
    }

    parsed_url = urllib.parse.urlparse(upload_url)
    http_conn = http.client.HTTPSConnection(parsed_url.netloc, 443)
    http_conn.request("PUT", upload_url, apk_bytes, headers)
    http_resp = http_conn.getresponse()

    # Wait for upload to be processed
    while True:
        resp = devicefarm.get_upload(arn=upload_arn)

        if(resp['upload']['status'] == "SUCCEEDED"):
            break
        if(resp['upload']['status'] == "FAILED"):
            break
        time.sleep(5)

        # Schedule run
        resp = devicefarm.schedule_run(
        projectArn=project_arn,
        appArn=upload_arn,
        devicePoolArn=devicepool_arn,
        name="android_run",
        test={
            "type" : "BUILTIN_FUZZ"
        }
        )

def lambda_handler(event, context):
    print('event received--->', event)
    try:
        project_arn = os.environ['PROJECT_ARN']
        android_devicepool_arn = os.environ['ANDROID_DEVICEPOOL_ARN']
        # ios_devicepool_arn = os.environ['IOS_DEVICEPOOL_ARN']
        bucket_name = event['bucket_name']
        key_name = event['key_name']

        start_test(bucket_name, key_name, project_arn, android_devicepool_arn)

    except Exception as e:
        print(e)

    return True