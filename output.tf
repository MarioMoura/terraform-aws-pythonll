output "input" {
  value = data.external.install_pkgs.result.input
}
output "reqs" {
  value = local.requirements_str
}
output "layersize" {
  value = data.external.install_pkgs.result.layersize
}

output "arn" {
  value = aws_lambda_layer_version.lambda_layer.arn
}
