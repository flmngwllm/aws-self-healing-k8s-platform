import boto3
import os
import time


sns = boto3.client('sns', region_name='us-east-1')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')

dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
DYNAMODB_TABLE_NAME = os.getenv('DYNAMODB_TABLE_NAME')


def send_sns_alert(alert_id, severity, message):
    if not SNS_TOPIC_ARN:
        print("SNS_TOPIC_ARN is not set. Unable to send alert.")
        return
    
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"Self-Heal Alert: {severity}",
        Message=f"Alert ID: {alert_id}\nSeverity: {severity}\nMessage: {message}"
    )


def save_alert_to_dynamodb(alert_id, severity, message):
    if not DYNAMODB_TABLE_NAME:
        print("DYNAMODB_TABLE_NAME does not exist. Unable to save alert.")
        return

    table = dynamodb.Table(DYNAMODB_TABLE_NAME)
    table.put_item(
        Item={
            'incident_id': alert_id,
            'severity': severity,
            'alert_message': message,
            'timestamp': int(time.time()),
            'status': 'open',
            'remediation_action': None,
        }
    )
