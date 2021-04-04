
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
  aliases           = ["file.${var.domain}"]
  dns_alias_enabled = true
  parent_zone_name  = var.zone 

  acm_certificate_arn = local.certificate_arn
}
