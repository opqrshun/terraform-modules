/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the bucket and registry; typically `us-east-1`.
# Other possible values: `us-east-2`, `us-west-1`, or `us-west-2`.
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "us-east-1"
}

# Name of the application. This value should usually match the application tag below.
variable "app" {
}

# The environment that is being built
variable "environment" {
}

variable "domain" {
}

variable "availability_zones" {
  type        = list(string)
  default     = ["a","b","c"]
}

# A map of the tags to apply to various resources. The required tags are:
# `application`, name of the app;
# `environment`, the environment being created;
# `team`, team responsible for the application;
# `contact-email`, contact email for the _team_;
# and `customer`, who the application was create for.
variable "tags" {
  type = map(string)
}
