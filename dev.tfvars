# app/env to scaffold
app = "sample"
environment = "dev"

# nlb
internal = true
health_check = "/health"

# ecs
container_port = "8080"
replicas = "1"

region = "us-east-1"
aws_profile = "default"

domain = "sample.com"
zone = "sample.com"

rds_password = "password"
public_key   = "ssh-rsa AAA"
tags = {
  application   = "sample"
  environment   = "dev"
}

saml_role = "admin"
secrets_saml_users = []
