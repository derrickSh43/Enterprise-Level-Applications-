provider "aws" {
  region = var.aws_region
}

# Media Storage Bucket
resource "aws_s3_bucket" "media_storage" {
  bucket = var.media_bucket_name

  acl    = "private"  # Keep media storage private

  tags = {
    Name        = "Media Storage"
    Environment = var.environment
  }
}

# IAM Policy for Presigned URLs
resource "aws_iam_policy" "s3_presigned_url_policy" {
  name        = "S3PresignedURLPolicy"
  description = "Policy to allow generating presigned URLs for S3 objects"

  policy = file("${path.module}/policy.json")
}

# IAM Role for Application
resource "aws_iam_role" "application_role" {
  name = "${var.environment}-ApplicationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"  # Change this if you're using a different service
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.s3_presigned_url_policy.arn
  role       = aws_iam_role.application_role.name
}