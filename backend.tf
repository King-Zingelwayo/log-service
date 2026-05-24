terraform {
  backend "s3" {
    bucket       = "tf-state-king-zinge-log-service-58558"
    key          = "main/terraform.tfstate"
    region       = "eu-west-1"
    encrypt      = true
    use_lockfile = true
  }
}