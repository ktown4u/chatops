output "post_functional_url" {
  description = "scale event를 생성하는 이벤트 엔드포인트"
  value       = aws_lambda_function_url.create-ecr.function_url
}
