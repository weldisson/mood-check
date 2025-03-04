import json
import boto3
import os
import requests

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['QUESTIONS_TABLE'])

def fetch_gifs_for_mood(mood_keyword, api_key):
    """Fetch GIFs from Giphy API based on mood keyword"""
    url = "https://api.giphy.com/v1/gifs/search"
    params = {
        'api_key': api_key,
        'q': mood_keyword,
        'limit': 3,
        'rating': 'g'
    }
    
    try:
        response = requests.get(url, params=params)
        response.raise_for_status()
        gifs = response.json().get('data', [])
        
        gif_urls = [
            gif['images']['fixed_height']['url'] 
            for gif in gifs 
            if 'images' in gif and 'fixed_height' in gif['images']
        ]
        
        return gif_urls
    except Exception as e:
        print(f"Erro to search GIFs: {e}")
        return []

def lambda_handler(event, context):
    try:
        response = table.scan()
        questions = response.get('Items', [])
        
        giphy_api_key = os.environ['GIPHY_API_KEY']
        
        for question in questions:
            if question.get('type') == 'gif_selection':
                options = []
                for option in question.get('options', []):
                    gifs = fetch_gifs_for_mood(option, giphy_api_key)
                    options.append({
                        'text': option,
                        'gifs': gifs
                    })
                question['options'] = options
        
        return {
            'statusCode': 200,
            'body': json.dumps(questions),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }
    
    except Exception as e:
        print(f"Erro to process questions: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            }
        }