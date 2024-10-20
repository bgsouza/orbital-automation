output "cloudfront_url" {
  description = "CloudFront URL para acessar o front-end"
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
}


output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.frontend_distribution.id
  description = "ID da distribuição do CloudFront"
}
