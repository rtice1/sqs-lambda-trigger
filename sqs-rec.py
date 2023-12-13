import boto3
import os

def receive_message_from_sqs(queue_url):
    # Create an SQS client
    sqs = boto3.client('sqs')

    # Receive message from SQS queue
    response = sqs.receive_message(
        QueueUrl=queue_url,
        AttributeNames=[
            'All'
        ],
        MaxNumberOfMessages=1,
        MessageAttributeNames=[
            'All'
        ],
        VisibilityTimeout=0,
        WaitTimeSeconds=0
    )

    if 'Messages' in response:
        message = response['Messages'][0]
        receipt_handle = message['ReceiptHandle']

        print(f"Received message: {message['Body']}")

        # Delete received message from queue
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        print("Message deleted")

def lambda_handler(event, context):
    # Get the SQS queue URL from environment variables
    queue_url = os.environ['QUEUE_URL']

    # Receive and process message from SQS
    receive_message_from_sqs(queue_url)

    return {
        'statusCode': 200,
        'body': 'Message received and processed from SQS'
    }
