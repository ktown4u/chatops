# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = local.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

# IAM policy for DynamoDB access
resource "aws_iam_role_policy" "dynamodb_policy" {
  name = "${local.name}-table"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:*"]
        Resource = [aws_dynamodb_table.slack_bot_context_db.arn]
      }
    ]
  })
}

# IAM policy for Bedrock access
resource "aws_iam_role_policy" "lambda_invoke_bedrock_model" {
  name = "lambda_invoke_bedrock_model"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-*",
          "arn:aws:bedrock:*::foundation-model/stability.stable-diffusion-*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "AmazonBedrockExecutionRoleForKnowledgeBase" {
  name = "AmazonBedrockExecutionRoleForKnowledgeBase"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = ["${local.account_id}"]
          }
          ArnLike = {
            "aws:SourceArn" = ["arn:aws:bedrock:${local.region}:${local.account_id}:knowledge-base/*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "AmazonBedrockExecutionRoleForKnowledgeBase" {
  name = "bedrock_execution_policy"
  role = aws_iam_role.AmazonBedrockExecutionRoleForKnowledgeBase.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3ListBucketStatement"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = [aws_s3_bucket.knowledgebase_source.arn]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = ["${local.account_id}"]
          }
        }
      },
      {
        Sid      = "S3GetObjectStatement"
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = ["${aws_s3_bucket.knowledgebase_source.arn}/*"]
        Condition = {
          StringEquals = {
            "aws:ResourceAccount" = ["${local.account_id}"]
          }
        }
      },
      {
        Sid      = "KnowledgeBaseAccessIndex"
        Effect   = "Allow"
        Action   = ["aoss:*"]
        Resource = ["arn:aws:aoss:${local.region}:${local.account_id}:collection/*"]
      },
      {
        Sid    = "KnowledgeBaseSyncIndex"
        Effect = "Allow"
        Action = ["bedrock:InvokeModel"]
        Resource = [
          "arn:aws:bedrock:*::foundation-model/amazon.titan-*",
          "arn:aws:bedrock:*::foundation-model/anthropic.claude-*",
        ]
      }
    ]
  })
}
