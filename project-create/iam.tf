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

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryFullAccess" {
  name = "AmazonEC2ContainerRegistryFullAccess"
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

resource "aws_iam_role" "create-ecr" {
  name               = "create-ecr"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn,
    data.aws_iam_policy.AmazonEC2ContainerRegistryFullAccess.arn

  ]
}
