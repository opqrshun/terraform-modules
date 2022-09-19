data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/${var.environment}/terraform.tfstate"
  }
}

locals {
  certificate_arn = data.terraform_remote_state.base.outputs.certificate_arn
  zone_id         = data.terraform_remote_state.base.outputs.zone_id
}


provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.aws_profile
}

resource "aws_acm_certificate" "virginia_certificate" {
  provider                  = aws.virginia
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "virginia_record" {
  provider = aws.virginia
  for_each = {
    for dvo in aws_acm_certificate.virginia_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 300
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "virginia_validation" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.virginia_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.virginia_record : record.fqdn]
}

