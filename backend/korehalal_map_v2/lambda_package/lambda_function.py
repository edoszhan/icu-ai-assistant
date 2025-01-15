import os
import json
from openai import OpenAI

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        user_prompt = body.get('prompt', 'No prompt provided')
        
        instruction = "You are a helpful assistant."
        
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": instruction},
                {"role": "user", "content": user_prompt}
            ],
            max_tokens=300
        )
        
      
        generated_text = response.choices[0].message.content.strip()
   
        return {
            'statusCode': 200,
            'body': json.dumps({
                'response': generated_text,
                'prompt_tokens': response.usage.prompt_tokens,
                'completion_tokens': response.usage.completion_tokens
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f"Error generating response: {str(e)}"
            })
        }
