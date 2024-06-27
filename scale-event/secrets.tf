data "aws_ssm_parameter" "slack-token" {
  name = "/chatops/slack/token"
}

data "aws_ssm_parameter" "signing-secret" {
  name = "/chatops/slack/signing-secret"
}

data "aws_ssm_parameter" "github-token" {
  name = "/chatops/github/pat-token"
}

