data "archive_file" "create-ecr" {
  type        = "zip"
  source_file = "create-ecr.py"
  output_path = "create-ecr.zip"
}
resource "aws_lambda_function" "create-ecr" {
  function_name    = "create-ecr"
  role             = aws_iam_role.create-ecr.arn
  handler          = "create-ecr.lambda_handler"
  filename         = data.archive_file.create-ecr.output_path
  source_code_hash = data.archive_file.create-ecr.output_base64sha256
  runtime          = local.python_runtime
}

resource "aws_lambda_function_url" "create-ecr" {
  function_name      = aws_lambda_function.create-ecr.function_name
  authorization_type = "NONE"
  invoke_mode        = "BUFFERED"
}
