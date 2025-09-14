locals {
  working_dir      = "${path.module}/${var.layer_name}"
  requirements_str = join(" ", var.requirements)
}
# Installation phase - Docker-based pip install with full logging
resource "terraform_data" "install_packages" {
  triggers_replace = [
    join(" ", var.requirements)
  ]

  provisioner "local-exec" {
    command = "${path.module}/install.sh"
    environment = {
      PYTHON_VERSION = var.python_version
      WORKING_DIR    = local.working_dir
      REQUIREMENTS   = local.requirements_str
    }
  }
}

data "archive_file" "layer_zip" {
  source_dir  = local.working_dir
  type        = "zip"
  output_path = "${path.module}/${var.layer_name}.zip"
  depends_on = [
    terraform_data.install_packages
  ]
}
resource "terraform_data" "replacement" {
  input = join(" ", var.requirements)
}
resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.layer_zip.output_path
  layer_name = var.layer_name_prefix == null ? var.layer_name : "${var.layer_name_prefix}-${var.layer_name}"

  description = "Python ${var.python_version} layer"

  skip_destroy = true

  compatible_runtimes = ["python3.13"]
  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}
