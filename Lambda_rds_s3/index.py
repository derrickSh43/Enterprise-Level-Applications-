import json
import boto3
import os
import pymysql

# Initialize S3 client
s3_client = boto3.client('s3')

# Retrieve RDS connection details from environment variables
rds_host = os.environ['RDS_HOST']
rds_user = os.environ['RDS_USER']
rds_password = os.environ['RDS_PASSWORD']
rds_db_name = os.environ['RDS_DB_NAME']

def upload_to_s3(bucket_name, file_name, file_content):
    # Upload the file content to S3
    s3_client.put_object(Bucket=bucket_name, Key=file_name, Body=file_content)
    return f"s3://{bucket_name}/{file_name}"

def save_to_rds(profile_data):
    # Connect to the RDS instance
    connection = pymysql.connect(
        host=rds_host,
        user=rds_user,
        password=rds_password,
        database=rds_db_name
    )

    try:
        with connection.cursor() as cursor:
            # Prepare the SQL statement for inserting profile data
            sql = "INSERT INTO profiles (username, text_content, image_url, video_url) VALUES (%s, %s, %s, %s)"
            cursor.execute(sql, (profile_data['username'], profile_data['text_content'], profile_data['image_url'], profile_data['video_url']))
        connection.commit()  # Commit the transaction
    finally:
        connection.close()  # Ensure the connection is closed

def lambda_handler(event, context):
    # Parse the incoming event
    try:
        body = json.loads(event['body'])
        username = body['username']
        text_content = body['text_content']
        image_data = body['image_data']  # Base64 encoded image data
        video_url = body.get('video_url', None)

        # Define S3 bucket and file name
        bucket_name = os.environ['S3_BUCKET_NAME']
        file_name = f"{username}/profile_image.png"  # Customize the file name

        # Upload image to S3
        image_url = upload_to_s3(bucket_name, file_name, image_data)

        # Prepare profile data for RDS
        profile_data = {
            'username': username,
            'text_content': text_content,
            'image_url': image_url,
            'video_url': video_url
        }

        # Save profile data to RDS
        save_to_rds(profile_data)

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Profile updated successfully!'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }