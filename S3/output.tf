output "media_bucket_name" {
  description = "The name of the media storage S3 bucket"
  value       = aws_s3_bucket.media_storage.bucket
}

output "application_role_arn" {
  description = "The ARN of the application IAM role"
  value       = aws_iam_role.application_role.arn
}

output "s3_presigned_url_policy_arn" {
  description = "The ARN of the S3 presigned URL policy"
  value       = aws_iam_policy.s3_presigned_url_policy.arn
}