/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

variable "aws_profile" {
}

# The AWS region to use for the dev environment's infrastructure
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "us-east-1"
}

variable "domain" {
}

variable "zone" {
}

variable "cert_arn" {
}

# The application's name
variable "app" {
}

# The environment that is being built
variable "environment" {
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}
