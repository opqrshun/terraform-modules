
data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/dev/terraform.tfstate"
  }
}

locals {
  certificate_arn = data.terraform_remote_state.base.outputs.certificate_arn
}


module "cdn" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  name             = "${var.app}-${var.environment}-public-files"
  aliases           = ["cdn.${var.domain}"]
  dns_alias_enabled = true
  parent_zone_name  = var.zone 

  acm_certificate_arn = local.certificate_arn
}


resource "aws_iam_role" "app_role" {
  name               = "${var.app}-${var.environment}-s3-role"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

# assigns the app policy
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.app}-${var.environment}-s3-policy"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

# TODO: fill out custom policy
data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-public-files"
    ]
  }

  statement {
    actions = [
      "s3:*Object"
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-public-files/*"
    ]
  }
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
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

