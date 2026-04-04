import boto3
import os


sns = boto3.client('sns', region_name='us-east-1')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN')

def send_sns_alert(alert_id, severity, message):
    if not SNS_TOPIC_ARN:
        print("SNS_TOPIC_ARN is not set. Unable to send alert.")
        return
    
    sns.publish(
        TopicArn=SNS_TOPIC_ARN,
        Subject=f"Self-Heal Alert: {severity}",
        Message=f"Alert ID: {alert_id}\nSeverity: {severity}\nMessage: {message}"
    )

