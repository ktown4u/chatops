# DynamoDB table
resource "aws_dynamodb_table" "slack_bot_context_db" {
  name           = var.DYNAMODB_TABLE_NAME
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expire_at"
    enabled        = true
  }
}
