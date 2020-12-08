provider "aws" {
  region = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
	  "Version": "2012-10-17",
	  "Statement": [
		{
		  "Action": "sts:AssumeRole",
		  "Principal": {
			"Service": "lambda.amazonaws.com"
		  },
		  "Effect": "Allow",
		  "Sid": ""
		}
	  ]
	}
	EOF
}

# Cloudwatch config
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  policy = <<EOF
{
	  "Version": "2012-10-17",
	  "Statement": [
		{
		  "Action": [
			"logs:CreateLogGroup",
			"logs:CreateLogStream",
			"logs:PutLogEvents"
		  ],
		  "Resource": "arn:aws:logs:*:*:*",
		  "Effect": "Allow"
		}
	  ]
	}
	EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

data "archive_file" "greet_lambda" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "var.lambda_zip_location"
}

# Lambda function
resource "aws_lambda_function" "greet_lambda" {
  function_name = "greet_lambda"
  filename = "var.lambda_zip_location"
  handler = "greet_lambda.lambda_handler"
  runtime = "python3.8"
  role = aws_iam_role.iam_for_lambda.arn
  environment{
      variables = {
          greeting = "Hello World from Lambda via Terraform!"
      }
  }
}
