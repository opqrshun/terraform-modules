variable "lambda_function_name" {
  default = "lambda-edge"
}

resource "aws_iam_role" "lambda-edge-iam" {
  name = "${var.app}-${var.environment}-lambda-edge-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda-edge-s3-iam" {
  name = "${var.app}-${var.environment}-lambda-edge-s3-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "edgelambda.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "lambda-edge-s3-policy" {
  name = "${var.app}-${var.environment}-lambda-edge-s3-policy"
  # (Optional, default "/") Path in which to create the policy. See IAM Identifiers for more information.
  path = "/"

  # TODO resource
  policy = data.aws_iam_policy_document.lambda-edge-s3-policy.json
}

# 画像圧縮用
data "aws_iam_policy_document" "lambda-edge-s3-policy" {

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-public-files-origin/*",
    ]
  }
}

resource "aws_iam_role_policy_attachment" "lambda-edge-s3-policy-attachment" {
  role       = aws_iam_role.lambda-edge-s3-iam.name
  policy_arn = aws_iam_policy.lambda-edge-s3-policy.arn
}


# # This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# # If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
# resource "aws_cloudwatch_log_group" "lambda-edge-log-group-origin-response" {
#   provider         = aws.virginia
#   name              = "/aws/lambda/${var.app}-${var.environment}-${var.lambda_function_name}-origin-response"
#   retention_in_days = 14
# }
# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda-edge-log-group-viewer-response" {
  provider          = aws.virginia
  name              = "/aws/lambda/${var.app}-${var.environment}-${var.lambda_function_name}-viwer-response"
  retention_in_days = 14
}

resource "aws_iam_role_policy_attachment" "lambda-edge-attachment" {
  role       = aws_iam_role.lambda-edge-iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-edge-s3-attachment" {
  role       = aws_iam_role.lambda-edge-s3-iam.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

###
resource "aws_lambda_function" "lambda-edge-viewer-request" {
  provider      = aws.virginia
  filename      = "../../lambda/viewer-request-function.zip"
  function_name = "${var.app}-${var.environment}-${var.lambda_function_name}-viewer-request"
  role          = aws_iam_role.lambda-edge-iam.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../lambda/viewer-request-function.zip")

  runtime     = "nodejs14.x"
  publish     = true
  memory_size = 128
  timeout     = 3
}

resource "aws_lambda_function" "lambda-edge-viewer-response" {
  provider      = aws.virginia
  filename      = "../../lambda/viewer-response-function.zip"
  function_name = "${var.app}-${var.environment}-${var.lambda_function_name}-viewer-response"
  role          = aws_iam_role.lambda-edge-iam.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../lambda/viewer-response-function.zip")

  runtime     = "nodejs14.x"
  publish     = true
  memory_size = 128
  timeout     = 3
}

resource "aws_lambda_function" "lambda-edge-origin-response" {
  provider      = aws.virginia
  filename      = "../../lambda/origin-response-function.zip"
  function_name = "${var.app}-${var.environment}-${var.lambda_function_name}-origin-response"
  role          = aws_iam_role.lambda-edge-s3-iam.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../lambda/origin-response-function.zip")

  runtime     = "nodejs14.x"
  publish     = true
  memory_size = 128
  timeout     = 3
}

resource "aws_lambda_function" "lambda-edge-main" {
  provider      = aws.virginia
  filename      = "../../lambda/viewer-response-function.zip"
  function_name = "${var.app}-${var.environment}-${var.lambda_function_name}"
  role          = aws_iam_role.lambda-edge-iam.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../lambda/viewer-response-function.zip")

  runtime     = "nodejs14.x"
  publish     = true
  memory_size = 128
  timeout     = 3
}