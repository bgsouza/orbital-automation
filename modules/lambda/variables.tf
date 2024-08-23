variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket where the deployment package is stored"
  type        = string
}

variable "s3_key" {
  description = "S3 key for the deployment package"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role for Lambda"
  type        = string
}
