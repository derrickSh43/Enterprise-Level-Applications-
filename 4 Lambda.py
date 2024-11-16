import json
import boto3
import pymysql  # RDS MySQL or Aurora Connector
import base64
from botocore.exceptions import ClientError

# Initialize AWS clients
s3_client = boto3.client('s3')
cognito_client = boto3.client('cognito-idp')


def get_database_credentials():
    # Retrieve credentials securely from AWS Secrets Manager
    client = boto3.client("secretsmanager")
    secret_name = "my-db-credentials"
    get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    secret = json.loads(get_secret_value_response["SecretString"])
    return secret

def lambda_handler(event, context):
    # Get database credentials securely
    db_credentials = get_database_credentials()
    
    # Use the credentials to connect to RDS
    connection = pymysql.connect(
        host='your-db-instance.rds.amazonaws.com',
        user=db_credentials['username'],
        password=db_credentials['password'],
        database='blog_database'
    )




def lambda_handler(event, context):
    try:
        # Step 1: Validate the Cognito token
        token = event['headers'].get('Authorization')
        if not token:
            return {'statusCode': 401, 'body': 'Unauthorized'}
        
        user_id = validate_cognito_token(token)
        if not user_id:
            return {'statusCode': 403, 'body': 'Forbidden'}
        
        # Step 2: Parse request data
        blog_text = event['body']['text']
        media = event['body'].get('media')  # Should contain media in base64 format
        
        # Step 3: Upload media to S3 if present
        media_url = None
        if media:
            media_bytes = base64.b64decode(media)
            media_key = f'blog-media/{user_id}/{context.aws_request_id}.jpg'
            s3_client.put_object(
                Bucket='media_storage',
                Key=media_key,
                Body=media_bytes,
                ContentType='image/jpeg'
            )
            media_url = f'https://{s3_client.meta.endpoint_url}/media_storage',/{media_key}'
        
        # Step 4: Store blog post details in RDS
        connection = pymysql.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name
        )
        with connection.cursor() as cursor:
            insert_blog_post(cursor, user_id, blog_text, media_url)
            connection.commit()
        
        return {'statusCode': 200, 'body': 'Blog updated successfully'}
    
    except Exception as e:
        print("Error:", e)
        return {'statusCode': 500, 'body': 'Internal Server Error'}

def validate_cognito_token(token):
    # Decode and validate the JWT token using Cognito
    try:
        response = cognito_client.get_user(AccessToken=token)
        return response['Username']
    except ClientError as e:
        print("Cognito validation failed:", e)
        return None

def insert_blog_post(cursor, user_id, text, media_url):
    sql = """
    INSERT INTO blog_posts (user_id, text, media_url, created_at)
    VALUES (%s, %s, %s, NOW())
    """
    cursor.execute(sql, (user_id, text, media_url))
