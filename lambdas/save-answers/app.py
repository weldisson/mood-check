import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['ANSWERS_TABLE'])

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}'))
        
        answer_id = str(uuid.uuid4())
        
        timestamp = datetime.utcnow().isoformat()
        
        item = {
            'answer_id': answer_id,
            'timestamp': timestamp,
            'answers': body.get('answers', [])
        }
        
        table.put_item(Item=item)
        
        return {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Respostas salvas com sucesso',
                'answer_id': answer_id,
                'timestamp': timestamp
            }),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    
    except Exception as e:
        print(f"Erro ao salvar respostas: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }