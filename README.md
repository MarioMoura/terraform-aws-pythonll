# Usage

This module creates AWS Lambda layers automatically from a list of Python dependencies.

```
module "python_layer" {
  source            = "MarioMoura/pythonll/aws"
  layer_name        = "my_python_layer"
  layer_name_prefix = var.environment
  requirements = [
    "requests==2.32.3",
    "numpy==2.1.0",
  ]
}
```
