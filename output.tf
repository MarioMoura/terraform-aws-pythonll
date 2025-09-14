output "reqs" {
  value = local.requirements_str
}
output "layersize" {
  value = data.external.layer_info.result.layersize
}
output "arn" {
  value = aws_lambda_layer_version.lambda_layer.arn
}
