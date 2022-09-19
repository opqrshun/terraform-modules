variable "lambda_function_name_tile" {
  default = "lambda-edge-tile"
}

# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda-edge-log-group-tile" {
  provider         = aws.virginia
  name              = "/aws/lambda/${var.app}-${var.environment}-${var.lambda_function_name_tile}"
  retention_in_days = 14
}


resource "aws_lambda_function" "lambda-edge-tile" {
  provider         = aws.virginia
  filename      = "../../lambda/viewer-response-function-tile.zip"
  function_name = "${var.app}-${var.environment}-${var.lambda_function_name_tile}"
  role          = aws_iam_role.lambda-edge-iam.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("../../lambda/viewer-response-function-tile.zip")

  runtime = "nodejs12.x"
  publish = true
  memory_size = 128
  timeout     = 3
}
