
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


resource "aws_cloudfront_distribution" "ogp_distribution" {

  enabled             = true
  aliases           = ["ogp.${var.domain}"]

  origin {
    domain_name           = "origin.${var.domain}"
    origin_id   = "${var.app}-${var.environment}-origin" 

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "match-viewer"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    # ... other configuration ...
    target_origin_id = "${var.app}-${var.environment}-origin"
    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = aws_lambda_function.lambda-edge-viewer-request-ogp.qualified_arn
      include_body = false
    }
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    viewer_protocol_policy = "allow-all"

    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#forwarded-values-arguments
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

  }
   restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn = var.cert_arn
    ssl_support_method = "sni-only"
  }

  tags = var.tags
}
