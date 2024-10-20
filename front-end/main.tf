provider "aws" {
  region = var.aws_region
  profile = var.profile
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.frontend_app}-bucket-${terraform.workspace}"
  acl    = "public-read"
}

# Resource que cria o CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.frontend_app}-${terraform.workspace}"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.frontend_app}-${terraform.workspace}"
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Output para a URL do CloudFront
output "cloudfront_url" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}
