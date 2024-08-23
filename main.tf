module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
}

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
}

module "lambda" {
  source = "./modules/lambda"
  function_name = "my_lambda_function"
  s3_bucket = module.s3.bucket_name
}
