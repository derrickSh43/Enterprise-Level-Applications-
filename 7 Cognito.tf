resource "aws_cognito_user_pool" "example" {
# ... other configuration ...


  mfa_configuration          = "ON"
  sms_authentication_message = "Your code is {####}"

  sms_configuration {
    external_id    = "example"
    sns_caller_arn = aws_iam_role.example.arn
    sns_region     = "us-east-1"
  }

  software_token_mfa_configuration {
    enabled = true
  }
}