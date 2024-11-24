locals {
  runtime            = "python3.13"
  name               = "ktown4u_porunga"
  lambda_memory_size = "1024"
  lambda_timeout     = 600
  account_id         = data.aws_caller_identity.current.account_id
  region             = "us-east-1"
}

data "aws_caller_identity" "current" {}

variable "AWS_REGION" {
  type = string
}
# The cursor icon to display while the bot is processing
variable "BOT_CURSOR" {
  type      = string
  sensitive = true
}

# Slack bot authentication token
variable "SLACK_BOT_TOKEN" {
  type      = string
  sensitive = true
}

# Slack signing secret for request verification
variable "SLACK_SIGNING_SECRET" {
  type      = string
  sensitive = true
}

# DynamoDB table name for storing bot context
variable "DYNAMODB_TABLE_NAME" {
  type = string
}

# Knowledge base identifier
variable "KNOWLEDGE_BASE_ID" {
  type = string
}

# Model ID for text generation
variable "MODEL_ID_TEXT" {
  type = string
}

# Model ID for image generation
variable "MODEL_ID_IMAGE" {
  type = string
}

# List of allowed Slack channel IDs
variable "ALLOWED_CHANNEL_IDS" {
  type = string
}

# System message defining bot behavior and personality
variable "SYSTEM_MESSAGE" {
  type = string
}

# Personal message defining bot identity
variable "PERSONAL_MESSAGE" {
  type = string
}

variable "KB_RETRIEVE_COUNT" {
  type = string
}
variable "ANTHROPIC_VERSION" {
  type = string
}

variable "ANTHROPIC_TOKENS" {
  type = string
}

variable "MAX_LEN_SLACK" {
  type = string
}
variable "MAX_LEN_BEDROCK" {
  type = string
}
variable "SLACK_SAY_INTERVAL" {
  type = string
}


