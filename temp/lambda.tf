
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "functions/handler.py"
  output_path = "functions/lambda_function_payload.zip"
}

# Lambda function
resource "aws_lambda_function" "lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "${local.name}_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  architectures    = ["x86_64"]
  memory_size      = local.lambda_memory_size
  runtime          = local.runtime
  timeout          = local.lambda_timeout
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      BOT_CURSOR           = var.BOT_CURSOR
      SLACK_BOT_TOKEN      = var.SLACK_BOT_TOKEN
      SLACK_SIGNING_SECRET = var.SLACK_SIGNING_SECRET
      DYNAMODB_TABLE_NAME  = var.DYNAMODB_TABLE_NAME
      KNOWLEDGE_BASE_ID    = var.KNOWLEDGE_BASE_ID
      MODEL_ID_TEXT        = var.MODEL_ID_TEXT
      MODEL_ID_IMAGE       = var.MODEL_ID_IMAGE
      ALLOWED_CHANNEL_IDS  = var.ALLOWED_CHANNEL_IDS
      SYSTEM_MESSAGE       = var.SYSTEM_MESSAGE
      PERSONAL_MESSAGE     = var.PERSONAL_MESSAGE
      KB_RETRIEVE_COUNT    = var.KB_RETRIEVE_COUNT
      ANTHROPIC_VERSION    = var.ANTHROPIC_VERSION
      ANTHROPIC_TOKENS     = var.ANTHROPIC_TOKENS
      MAX_LEN_SLACK        = var.MAX_LEN_SLACK
      MAX_LEN_BEDROCK      = var.MAX_LEN_BEDROCK
      SLACK_SAY_INTERVAL   = var.SLACK_SAY_INTERVAL
    }
  }
  layers = [aws_lambda_layer_version.slack_bolt.arn]
}


# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}


resource "aws_lambda_layer_version" "slack_bolt" {
  filename            = "layers/slack_bolt_python_313.zip"
  layer_name          = "slack_bolt"
  compatible_runtimes = [local.runtime]
}
