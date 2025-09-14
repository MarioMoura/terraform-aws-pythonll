output "reqs" {
  value = local.requirements_str
}
output "arn" {
  value = aws_lambda_layer_version.lambda_layer.arn
}
