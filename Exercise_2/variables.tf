# TODO: Define the variable for aws_region
variable "aws_region" {
  type        = string
}
variable "function_name" {
    type        = string
    default = "greet_lambda"
}
variable "lambda_zip_location" {
  type    = list(string)
  default = ["outputs/greet_lambda.zip"]
}
