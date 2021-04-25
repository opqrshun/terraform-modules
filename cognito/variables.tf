/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "us-east-1"
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

# The application's name
variable "app" {
}

# The environment that is being built
variable "environment" {
}

variable "zone" {
  type        = string
  description = "The Route53 zone in which to add the DNS entry"
}

variable "domain" {
  type        = string
  description = "The domain name for your API Gateway endpoint"
}

# Google OAuth
variable "google_client_id" {
}

variable "google_client_secret" {
}

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/dev/terraform.tfstate"
  }
}

locals {
  namespace        = "${var.app}-${var.environment}"
  certificate_arn  = data.terraform_remote_state.base.outputs.certificate_arn
}

