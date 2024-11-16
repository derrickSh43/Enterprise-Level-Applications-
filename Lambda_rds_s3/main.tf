provider "aws" {
  region = "us-west-2"  # Change to your desired region
}

# S3 Bucket for storing profile images
resource "aws_s3_bucket" "profile_images" {
  bucket = var.profile_images_bucket_name  # Use a variable for the bucket name
  acl    = "private"

  tags = {
    Name        = "Profile Images Bucket"
    Environment = var.environment
  }
}

# IAM Role for Lambda Function
resource "aws_iam_role" "lambda_exec" {
  name = "${var.environment}-lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# Attach policy to allow Lambda to access S3 and Secrets Manager
resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "${var.environment}-lambda_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "lambda_s3_access" {
  name       = "${var.environment}-lambda_s3_access"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "lambda_secrets_manager_access" {
  name       = "${var.environment}-lambda_secrets_manager_access"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Lambda Function
resource "aws_lambda_function" "data_handler" {
  function_name = "${var.environment}-data_handler"
  handler       = "index.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn

  # Package the lambda function code
  filename      = "path/to/your/index.zip"  # Path to the zipped Lambda function code

  environment {
    variables = {
      RDS_HOST       = data.aws_ssm_parameter.rds_host.value
      S3_BUCKET_NAME = aws_s3_bucket.profile_images.bucket
      RDS_SECRET_ARN = aws_secretsmanager_secret.rds_secret.arn
    }
  }

  depends_on = [
    aws_iam_policy_attachment.lambda_policy,
    aws_iam_policy_attachment.lambda_s3_access,
    aws_iam_policy_attachment.lambda_secrets_manager_access
  ]
}

# SSM Parameter for RDS Host
data "aws_ssm_parameter" "rds_host" {
  name = "/myapp/rds_host"  # Change to your SSM parameter name
}

# Secrets Manager for RDS Credentials
resource "aws_secretsmanager_secret" "rds_secret" {
  name = "${var.environment}-rds_credentials"
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id     = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.rds_username  # Use a variable for the RDS username
    password = var.rds_password  # Use a variable for the RDS password
  })
}

# RDS Instance
resource "aws_db_instance" "default" {
  identifier         = "${var.environment}-my-rds-instance"
  engine             = "mysql"  # or "postgres", etc.
  instance_class     = "db.t2.micro"
  allocated_storage   = 20
  username           = jsondecode(aws_secretsmanager_secret_version.rds_secret_version.secret_string)["username"]
  password           = jsondecode(aws_secretsmanager_secret_version.rds_secret_version.secret_string)["password"]
  db_name            = var.rds_db_name  # Use a variable for the database name
  skip_final_snapshot = true

  tags = {
    Name        = "RDS Instance"
    Environment = var.environment
  }
}