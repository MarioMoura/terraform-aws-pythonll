variable "requirements" {
  description = "Python requirements"
  type        = list(string)
}
variable "layer_name" {
  description = "Name of the layer"
  type        = string
}
variable "layer_name_prefix" {
  description = "Generally the environment is used as prefix"
  type        = string
  default     = null
}
variable "platform" {
  description = "pip install platform"
  type        = string
  default     = "manylinux2014_x86_64"
}
variable "python_version" {
  description = "Python version"
  type        = string
  default     = "3.11"
}
variable "implementation" {
  description = "pip implementation"
  type        = string
  default     = "cp"
}
