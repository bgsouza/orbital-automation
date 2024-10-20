output "cloudfront_url" {
  description = "CloudFront URL para acessar o front-end"
  value       = aws_cloudfront_distribution.frontend_distribution.domain_name
}
