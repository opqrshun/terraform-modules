
data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/${var.environment}/terraform.tfstate"
  }
}

locals {
  zone_id = data.terraform_remote_state.base.outputs.zone_id
}


module "cdn" {
  source = "cloudposse/cloudfront-s3-cdn/aws"
  # Cloud Posse recommends pinning every module to a specific version
  # version     = "x.x.x"
  name              = "${var.app}-${var.environment}-public-files"
  aliases           = ["cdn.${var.domain}"]
  dns_alias_enabled = true
  parent_zone_name  = var.zone

  acm_certificate_arn = var.cert_arn

  lambda_function_association = [
    {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.lambda-edge-viewer-request.qualified_arn
    },
    {
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = aws_lambda_function.lambda-edge-origin-response.qualified_arn
    },
    {
      event_type   = "viewer-response"
      include_body = false
      lambda_arn   = aws_lambda_function.lambda-edge-viewer-response.qualified_arn
    }
  ]
}


resource "aws_s3_bucket" "bucket" {
  bucket = "${var.app}-${var.environment}-deleted-files"
  acl    = "private"

  lifecycle_rule {
    id      = "images"
    enabled = true

    prefix = "images/"

    tags = {
      status    = "deleted"
      autoclean = "true"
    }

    transition {
      days          = 7
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  tags = var.tags
}
