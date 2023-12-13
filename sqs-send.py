import boto3
import os

def send_message_to_sqs(message_body, queue_url):
    # Create an SQS client
    sqs = boto3.client('sqs')

    # Send a message to the queue
    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=message_body
    )

    return response['MessageId']

def lambda_handler(event, context):
    # Get the SQS queue URL from environment variables
    queue_url = os.environ['QUEUE_URL']
    
    # Example message to send
    message_body = "Hello from Lambda!"

    # Send the message to SQS
    message_id = send_message_to_sqs(message_body, queue_url)

    return {
        'statusCode': 200,
        'body': f'Message sent to SQS with ID: {message_id}'
    }
