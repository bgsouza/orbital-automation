variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "environment" {
  description = "environment"
  type        = string
}

variable "profile" {
  description = "Profile AWS Terraform"
  type        = string
}

variable "backend_app" {
  description = "Backend API name"
  type        = string
}