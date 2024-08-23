terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "global/terraform.tfstate"
    region = "us-west-2"
  }
}
