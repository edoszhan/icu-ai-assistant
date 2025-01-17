import os
import json
from openai import OpenAI

client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

def generate_general_response(user_prompt):
    try:
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
        usage = response.usage

        return {
            "response": generated_text,
            "prompt_tokens": usage.prompt_tokens,
            "completion_tokens": usage.completion_tokens
        }
    except Exception as e:
        raise Exception(f"Error generating response: {str(e)}")

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        user_prompt = body.get('prompt', 'No prompt provided')

        response_data = generate_general_response(user_prompt)

        return {
            'statusCode': 200,
            'body': json.dumps({
                'response': response_data['response'],
                'prompt_tokens': response_data['prompt_tokens'],
                'completion_tokens': response_data['completion_tokens']
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': f"Error generating response: {str(e)}"
            })
        }
