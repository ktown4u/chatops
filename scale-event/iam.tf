data "aws_iam_policy" "AWSLambdaDynamoDBExecutionRole" {
  name = "AWSLambdaDynamoDBExecutionRole"
}
# resource "aws_iam_policy" "update-aurora-asg-policy-for-scale-event" {
# 세부 권한은 추후에 반영
# 현재는 RDSFullAccess를 주었음. 보안이슈를 해결하기 위해서는 asg policy만 변경할 수 있는 권한으로 하향조정해야함.
#   name        = "update-aurora-asg-policy-for-scale-event"
#   path        = "/"
#   description = "aurora asg policy update"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "rds:Describe*",
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       },
#     ]
#   })
# }

data "aws_iam_policy" "AmazonRDSFullAccess" {
  name = "AmazonRDSFullAccess"
}

data "aws_iam_policy" "AWSLambda_FullAccess" {
  name = "AWSLambda_FullAccess"
}

data "aws_iam_policy" "AWSApplicationAutoscalingRDSClusterPolicy" {
  name = "AWSApplicationAutoscalingRDSClusterPolicy"
}

data "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  name = "AmazonDynamoDBFullAccess"
}
data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "check-scale-event-status" {
  name               = "check-scale-event-status"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaDynamoDBExecutionRole.arn,
    data.aws_iam_policy.AWSLambda_FullAccess.arn
  ]
}

resource "aws_iam_role" "post-scale-event-message" {
  name               = "post-scale-event-message"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaDynamoDBExecutionRole.arn,
    data.aws_iam_policy.AmazonDynamoDBFullAccess.arn
  ]
}

resource "aws_iam_role" "update-helm-value-for-scale-event" {
  name               = "update-helm-value-for-scale-event"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AmazonDynamoDBFullAccess.arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ]
}

resource "aws_iam_role" "update-aurora-asg-policy-for-scale-event" {
  name               = "update-aurora-asg-policy-for-scale-event"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AmazonRDSFullAccess.arn,
    data.aws_iam_policy.AmazonDynamoDBFullAccess.arn,
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  ]
}

resource "aws_iam_role" "update-scale-event-status" {
  name               = "update-scale-event-status"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaDynamoDBExecutionRole.arn
  ]
}
