terraform {
  backend "s3" {
    bucket         = "threatcomp-tfstate-bucket"
    key            = "infra/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "threatcomp-tfstate-lock"
    encrypt        = true
  }
}

