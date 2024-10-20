module "vpc" {
  source = "./vpc"
}

module "frontend" {
  source = "./front-end"
  aws_region = var.aws_region  # Passa a variável aws_region
  profile    = var.profile     # Passa a variável profile
  environment = var.environment
  frontend_app = var.frontend_app
}

module "backend" {
  source = "./back-end"
  aws_region = var.aws_region  # Passa a variável aws_region
  profile    = var.profile     # Passa a variável profile
  environment = var.environment
  backend_app = var.backend_app
}
