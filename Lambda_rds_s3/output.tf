variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "rds_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true  # Mark as sensitive to avoid logging
}

variable "rds_db_name" {
  description = "The name of the database for the RDS instance"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket where images will be uploaded"
  type        = string
}