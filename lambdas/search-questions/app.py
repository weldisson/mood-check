import json
import os
import boto3
import requests
from boto3.dynamodb.conditions import Key

# Initialize clients
dynamodb = boto3.resource('dynamodb')
questions_table = dynamodb.Table(os.environ['QUESTIONS_TABLE'])
giphy_api_key = os.environ['GIPHY_API_KEY']

def fetch_gifs_for_mood(mood_keyword, limit=3):
    """Fetch GIFs from Giphy API based on mood keyword"""
    url = "https://api.giphy.com/v1/gifs/search"
    params = {
        'api_key': giphy_api_key,
        'q': mood_keyword,
        'limit': limit,
        'rating': 'g'
    }
    
    response = requests.get(url, params=params)
    if response.status_code == 200:
        return response.json()['data']
    else:
        return []

def get_all_questions():
    """Fetch all questions from DynamoDB"""
    response = questions_table.scan()
    return response.get('Items', [])

def enrich_questions_with_gifs(questions):
    """Add GIF options to the question that requires GIFs"""
    for question in questions:
        if question.get('type') == 'gif_selection':
            options = question.get('options', [])
            enriched_options = []
            
            for option in options:
                gifs = fetch_gifs_for_mood(option, limit=1)
                gif_url = gifs[0]['images']['fixed_height']['url'] if gifs else ""
                
                enriched_options.append({
                    'text': option,
                    'gif_url': gif_url
                })
                
            question['options'] = enriched_options
    
    return questions

def lambda_handler(event, context):
    try:
        # Get all questions
        questions = get_all_questions()
        
        # Enrich questions with GIFs
        questions = enrich_questions_with_gifs(questions)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'questions': questions
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