locals {
  working_dir      = "${path.module}/${var.layer_name}"
  requirements_str = join(" ", var.requirements)
}
data "external" "install_pkgs" {
  program = ["bash", "${path.module}/pip_install.sh"]

  query = {
    python_version = var.python_version
    working_dir    = local.working_dir
    platform       = var.platform
    requirements   = local.requirements_str
    implementation = var.implementation
  }
}
data "archive_file" "layer_zip" {
  source_dir  = local.working_dir
  type        = "zip"
  output_path = ".arquive/${var.layer_name}.zip"
  depends_on = [
    data.external.install_pkgs
  ]
}
resource "terraform_data" "replacement" {
  input = join(" ", var.requirements)
}
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.layer_zip.output_path
  layer_name = var.layer_name_prefix == null ? var.layer_name : "${var.layer_name_prefix}-${var.layer_name}"

  description = "${data.external.install_pkgs.result.gitlog}:${data.external.install_pkgs.result.layersize}"

  skip_destroy = true

  compatible_runtimes = ["python3.11"]
  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}
output "trigger" {
  value = terraform_data.replacement.output
}
