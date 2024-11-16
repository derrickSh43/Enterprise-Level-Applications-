data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Package the Python file as a .zip
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambdapy.py"
  output_path = "lambdapy.zip"
}

# Package the Python layer file as a .zip
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir = "my_lambda_layer"
  output_path = "my_lambda_layer.zip"
}

# The lambda layer file
resource "aws_lambda_layer_version" "my_layer" {
  layer_name          = "my_lambda_layer"
  filename            = data.archive_file.lambda_layer_zip.output_path
  compatible_runtimes = ["python3.8", "python3.9", "python3.10"]  # Specify the Python versions you want to support
}

resource "aws_lambda_function" "lambdapy" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "lambda_function_name"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambdapy.lambda_handler"  # Assuming lambda_handler is your entry point
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.9"
  layers        = [aws_lambda_layer_version.my_layer.arn]
  

  environment {
    variables = {
      foo = "bar"
    }
  }
}
