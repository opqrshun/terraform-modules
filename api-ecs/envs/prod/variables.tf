/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
# Currently, Fargate is only available in `us-east-1`.
variable "region" {
  default = "ap-northeast-1"
}

# The AWS profile to use, this would be the same value used in AWS_PROFILE.
variable "aws_profile" {
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


variable "keybase_user" {
}

variable "api_audience" {
  default = "example"
}
variable "api_issuer" {
}


## ECS

# The port the container will listen on, used for load balancer health check
# Best practice is that this value is higher than 1024 so the container processes
# isn't running at root.


variable "container_image" {
}

variable "container_port" {
}

#variable "container_definitions" {
#}

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



# NLB

# The port the load balancer will listen on
variable "lb_port" {
  default = "80"
}

# The load balancer protocol
variable "lb_protocol" {
  default = "TCP"
}

#variable "saml_role" {
#}
#
#variable "secrets_saml_users" {
#}




