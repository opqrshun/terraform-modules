module "cdn-tile" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  name              = "${var.app}-${var.environment}-tile"
  aliases           = ["tile.${var.domain}", "a.tile.${var.domain}", "b.tile.${var.domain}", "c.tile.${var.domain}"]
  dns_alias_enabled = true
  parent_zone_name  = var.zone

  acm_certificate_arn = aws_acm_certificate.tile_certificate.arn

  allowed_methods = ["GET", "HEAD", "OPTIONS"]

  lambda_function_association = [{
    event_type   = "viewer-response"
    include_body = false
    lambda_arn   = aws_lambda_function.lambda-edge-tile.qualified_arn
  }]
}

resource "aws_iam_role" "app_role-tile" {
  name               = "${var.app}-${var.environment}-tile-s3-role"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy-tile.json
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy-tile" {
  name   = "${var.app}-${var.environment}-tile-s3-policy"
  role   = aws_iam_role.app_role-tile.id
  policy = data.aws_iam_policy_document.app_policy-tile.json
}

# TODO: fill out custom policy
data "aws_iam_policy_document" "app_policy-tile" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-tile"
    ]
  }

  statement {
    actions = [
      "s3:*Object"
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-tile/*"
    ]
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy-tile" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.aws_profile
}

resource "aws_acm_certificate" "tile_certificate" {
  provider                  = aws.virginia
  domain_name               = "tile.${var.domain}"
  validation_method         = "DNS"
  subject_alternative_names = ["*.tile.${var.domain}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "tile_record" {
  provider = aws.virginia
  for_each = {
    for dvo in aws_acm_certificate.tile_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "tile_validation" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.tile_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.tile_record : record.fqdn]
}

