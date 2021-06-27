/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
}

# The environment that is being built
variable "environment" {
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}


# DNS

# The application's name
variable "app" {
}

variable "zone" {
  type        = string
  description = "The Route53 zone in which to add the DNS entry"
}

variable "domain" {
  type        = string
  description = "The domain name for your API Gateway endpoint"
}


variable "private" {
  default = false
}



## ECS

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.



variable "container_port" {
}
variable "container_image" {
}

# How many containers to run
variable "replicas" {
}

# The minimum number of containers that should be running.
# Must be at least 1.
# used by both autoscale-perf.tf and autoscale.time.tf
# For production, consider using at least "2".
variable "ecs_autoscale_min_instances" {
  default = "1"
}

# The maximum number of containers that should be running.
# used by both autoscale-perf.tf and autoscale.time.tf
variable "ecs_autoscale_max_instances" {
  default = "2"
}

#variable "container_definitions" {
#}


# NLB

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "TCP"
}

variable "keybase_user" {
}

variable "api_audience" {
  default = "example"
}

variable "api_issuer" {
}

#variable "saml_role" {
#}
#
#variable "secrets_saml_users" {
#}

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/${var.environment}/terraform.tfstate"
  }
}

locals {
  namespace        = "${var.app}-${var.environment}"
  ssm-namespace        = "/${var.app}/${var.environment}"
  container_name        = "${var.app}-${var.environment}-app"
  # target_subnets   = data.terraform_remote_state.base.outputs.private_subnets
  target_subnets = "${var.private == true ? data.terraform_remote_state.base.outputs.private_subnets : data.terraform_remote_state.base.outputs.public_subnets }"
  vpc_id           = data.terraform_remote_state.base.outputs.vpc_id
  certificate_arn  = data.terraform_remote_state.base.outputs.certificate_arn
}

