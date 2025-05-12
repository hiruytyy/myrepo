import boto3
import urllib.parse
import logging
import os
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
logger = logging.getLogger()
logger.setLevel(logging.INFO)

XRAY_BUCKET = os.environ['XRAY_BUCKET']
CTSCAN_BUCKET = os.environ['CTSCAN_BUCKET']
GENERAL_BUCKET = os.environ['GENERAL_BUCKET']
CONFIDENCE_LEVEL = float(os.environ['CONFIDENCE_LEVEL'])

def lambda_handler(event, context):
    try:
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        image_key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'])
        logger.info(f"Processing file: {image_key} from bucket: {source_bucket}")

        response = rekognition.detect_labels(
            Image={'S3Object': {'Bucket': source_bucket, 'Name': image_key}},
            MaxLabels=10
        )

        for label in response.get("Labels", []):
            if label.get("Name") == "X-Ray" and label.get("Confidence", 0) >= CONFIDENCE_LEVEL:
                logger.info("X-Ray image detected, copying to XRAY bucket.")
                s3.copy_object(CopySource={'Bucket': source_bucket, 'Key': image_key}, Bucket=XRAY_BUCKET, Key=image_key)
                return {'statusCode': 200, 'body': f'X-Ray image copied to {XRAY_BUCKET}'}

            elif label.get("Name") == "Ct Scan" and label.get("Confidence", 0) >= CONFIDENCE_LEVEL:
                logger.info("Ct Scan image detected, copying to CT bucket.")
                s3.copy_object(CopySource={'Bucket': source_bucket, 'Key': image_key}, Bucket=CTSCAN_BUCKET, Key=image_key)
                return {'statusCode': 200, 'body': f'CT image copied to {CTSCAN_BUCKET}'}

        logger.info("No match found. Copying to GENERAL bucket.")
        s3.copy_object(CopySource={'Bucket': source_bucket, 'Key': image_key}, Bucket=GENERAL_BUCKET, Key=image_key)
        return {'statusCode': 200, 'body': f'Image copied to {GENERAL_BUCKET}'}

    except ClientError as e:
        logger.error(f"Client error: {e}")
        return {'statusCode': 500, 'body': str(e)}
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return {'statusCode': 500, 'body': str(e)}
 