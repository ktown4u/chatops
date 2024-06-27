resource "aws_dynamodb_table" "scale-event-dynamodb-table" {
  name           = "ktown4u-scale-event"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "request_id"
  range_key      = "request_user"

  attribute {
    name = "request_id"
    type = "S"
  }
  attribute {
    name = "request_user"
    type = "S"
  }
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
}

data "aws_iam_policy_document" "scale-event-dynamodb-table-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::170023315897:root"]
    }
    actions = [
      "dynamodb:PutItem"
    ]
    resources = [
      "arn:aws:dynamodb:ap-northeast-2:170023315897:table/ktown4u-scale-event"
    ]
  }
}

resource "aws_dynamodb_resource_policy" "scale-event-dynamodb-table-policy" {
  resource_arn = aws_dynamodb_table.scale-event-dynamodb-table.arn
  policy       = data.aws_iam_policy_document.scale-event-dynamodb-table-policy.json
}

resource "aws_lambda_event_source_mapping" "scale-event" {
  event_source_arn  = aws_dynamodb_table.scale-event-dynamodb-table.stream_arn
  function_name     = aws_lambda_function.check-scale-event-status.arn
  starting_position = "LATEST"
}
