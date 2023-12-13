variable "app_name" {
  description = "application name"
}
variable "runtime" {
  description = "lambda runtime"
}
variable "architecture" {
  default = "basic"
  description = "`basic` `sqs-send` and `sqs-rec` are accepted inputs"
}