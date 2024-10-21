
output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend_distribution.id
  description = "ID da distribuição do CloudFront"
}

output "cloudfront_domain" {
  description = "CloudFront Domain para acessar o front-end"
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
}

output "s3_website_url" {
  description = "URL do site estático diretamente no S3"
  value       = aws_s3_bucket.frontend_bucket.website_endpoint
}
