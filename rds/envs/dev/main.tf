
terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.35.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}


module "env" {
  source = "../../"

  region = var.region
  app = var.app
  environment = var.environment
  rds_password = var.rds_password
  tags = var.tags
  
}



