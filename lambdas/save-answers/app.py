import json
import os
import uuid
import boto3
from datetime import datetime

# Initialize clients
dynamodb = boto3.resource('dynamodb')
answers_table = dynamodb.Table(os.environ['ANSWERS_TABLE'])

def lambda_handler(event, context):
    try:
        # Parse request body
        body = json.loads(event['body'])
        
        # Extract user_id (generate anonymous one if not provided)
        user_id = body.get('user_id', f"anonymous-{str(uuid.uuid4())}")
        
        # Extract answers
        answers = body.get('answers', [])
        
        if not answers:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'No answers provided'
                })
            }
        
        # Generate unique answer ID
        answer_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        # Save to DynamoDB
        item = {
            'answer_id': answer_id,
            'user_id': user_id,
            'timestamp': timestamp,
            'answers': answers
        }
        
        answers_table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'answer_id': answer_id,
                'timestamp': timestamp
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }