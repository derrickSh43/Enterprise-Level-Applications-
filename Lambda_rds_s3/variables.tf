variable "s3_bucket_name" {
  description = "The name of the S3 bucket for profile images."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}

variable "lambda_code_s3_key" {
  description = "The S3 key for the Lambda function code."
  type        = string
}

variable "rds_instance_identifier" {
  description = "The identifier for the RDS instance."
  type        = string
}

variable "rds_host" {
  description = "The RDS instance endpoint."
  type        = string
}

variable "rds_user" {
  description = "The username for the RDS database."
  type        = string
}

variable "rds_password" {
  description = "The password for the RDS database."
  type        = string
}

variable "rds_db_name" {
  description = "The name of the RDS database."
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)."
  type        = string
}
variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-west-2"
}

variable "profile_images_bucket_name" {
  description = "The name of the S3 bucket for profile images"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "rds_password" {
  description = "The password for the RDS instance"
  type        = string
}

variable "rds_db_name" {
  description = "The name of the database for the RDS instance"
  type        = string
}
variable "rds_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "rds_password" {
  description = "The password for the RDS instance"
  type        = string
}

variable "rds_db_name" {
  description = "The name of the database for the RDS instance"
  type        = string
}