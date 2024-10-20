output "elastic_beanstalk_url" {
  description = "Elastic Beanstalk URL para acessar a API"
  value       = aws_elastic_beanstalk_environment.backend_env.endpoint_url
}
