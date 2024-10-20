variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "environment"
  type        = string
  default     = "dev"
}

variable "profile" {
  description = "Profile AWS Terraform"
  type        = string
  default     = "orbital"
}

variable "vpc_cidr_block" {
  description = "vpc_cidr_block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidr_block" {
  description = "subnet_cidr_block"
  type        = string
  default     = "10.1.1.0/24"
}

variable "frontend_app" {
  description = "Frontend APP"
  type        = string
  default     = "CoilFront"
}

variable "backend_app" {
  description = "Backend API name"
  type        = string
  default     = "CoilAPI"
}