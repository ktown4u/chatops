output "api_gateway_dns" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}${aws_api_gateway_stage.stage.stage_name}${aws_api_gateway_resource.slack_events.path}"
}
