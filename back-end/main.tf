provider "aws" {
  region = var.aws_region
  profile = var.profile
}

resource "aws_elastic_beanstalk_application" "backend_app" {
  name = "${var.backend_app}-app-${terraform.workspace}"
}

resource "aws_elastic_beanstalk_environment" "backend_env" {
  name                = "${var.backend_app}-env-${terraform.workspace}"
  application         = aws_elastic_beanstalk_application.backend_app.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.6 running PHP 7.4"
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.backend_app}-source"
}

resource "aws_s3_bucket_acl" "backend_bucket_acl" {
  bucket = aws_s3_bucket.backend_bucket.id  # Refere-se ao bucket criado
  acl    = "private"
}

