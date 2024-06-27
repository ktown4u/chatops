data "archive_file" "check-scale-event-status" {
  type        = "zip"
  source_file = "check-scale-event-status.py"
  output_path = "check-scale-event-status.zip"
}
resource "aws_lambda_function" "check-scale-event-status" {
  function_name    = "check-scale-event-status"
  role             = aws_iam_role.check-scale-event-status.arn
  handler          = "check-scale-event-status.lambda_handler"
  filename         = data.archive_file.check-scale-event-status.output_path
  source_code_hash = data.archive_file.check-scale-event-status.output_base64sha256
  runtime          = local.python_runtime
}

data "archive_file" "post-scale-event-message" {
  type        = "zip"
  source_file = "post-scale-event-message.py"
  output_path = "post-scale-event-message.zip"
}
resource "aws_lambda_function" "post-scale-event-message" {
  function_name    = "post-scale-event-message"
  role             = aws_iam_role.post-scale-event-message.arn
  handler          = "post-scale-event-message.lambda_handler"
  filename         = data.archive_file.post-scale-event-message.output_path
  source_code_hash = data.archive_file.post-scale-event-message.output_base64sha256
  runtime          = local.python_runtime
  timeout          = "10"
  environment {
    variables = {
      SLACK_TOKEN         = data.aws_ssm_parameter.slack-token.value
      SIGNING_SECRET      = data.aws_ssm_parameter.signing-secret.value
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.scale-event-dynamodb-table.name
    }
  }
}
resource "aws_lambda_function_url" "post-scale-event-message" {
  function_name      = aws_lambda_function.post-scale-event-message.function_name
  authorization_type = "NONE"
  invoke_mode        = "BUFFERED"
}


data "archive_file" "update-aurora-asg-policy-for-scale-event" {
  type        = "zip"
  source_file = "update-aurora-asg-policy-for-scale-event.py"
  output_path = "update-aurora-asg-policy-for-scale-event.zip"
}
resource "aws_lambda_function" "update-aurora-asg-policy-for-scale-event" {
  function_name    = "update-aurora-asg-policy-for-scale-event"
  role             = aws_iam_role.update-aurora-asg-policy-for-scale-event.arn
  handler          = "update-aurora-asg-policy-for-scale-event.lambda_handler"
  filename         = data.archive_file.update-aurora-asg-policy-for-scale-event.output_path
  source_code_hash = data.archive_file.update-aurora-asg-policy-for-scale-event.output_base64sha256
  runtime          = local.python_runtime
  timeout          = "10"
  environment {
    variables = {
      CLUSTER_IDENTIFIER = local.rds_cluster_identifier
    }
  }
}

data "archive_file" "update-helm-value-for-scale-event" {
  type        = "zip"
  source_file = "update-helm-value-for-scale-event.py"
  output_path = "update-helm-value-for-scale-event.zip"
}
resource "aws_lambda_function" "update-helm-value-for-scale-event" {
  function_name    = "update-helm-value-for-scale-event"
  role             = aws_iam_role.update-helm-value-for-scale-event.arn
  handler          = "update-helm-value-for-scale-event.lambda_handler"
  filename         = data.archive_file.update-helm-value-for-scale-event.output_path
  source_code_hash = data.archive_file.update-helm-value-for-scale-event.output_base64sha256
  runtime          = local.python_runtime
  timeout          = "10"
  environment {
    variables = {
      GITHUB_PAT_TOKEN     = data.aws_ssm_parameter.github-token.value
      API_ENDPOINT         = "/repos/ktown4u/scale-event-for-chatops/actions/workflows/"
      INCREASE_WORKFLOW_ID = "104493240"
      DECREASE_WORKFLOW_ID = "104493239"
    }
  }
}
