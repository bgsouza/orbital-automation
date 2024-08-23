resource "aws_lambda_function" "this" {
  function_name = var.function_name
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  handler       = "index.handler"
  runtime       = "nodejs14.x"
  role          = var.role_arn
}
