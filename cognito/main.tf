data "aws_route53_zone" "main" {
  name = var.zone
}

resource "aws_route53_record" "cognito" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "auth.${var.domain}"
  type    = "A"
  alias {
    name                   = module.aws_cognito_user_pool.domain_cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

module "aws_cognito_user_pool" {

  source = "lgallard/cognito-user-pool/aws"

  user_pool_name        = "${var.app}-${var.environment}-user-pool"
  
  #alias_attributes
  # username and alias
  username_attributes        = ["email"]
  auto_verified_attributes   = ["email"]

  mfa_configuration = "OFF"

  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false 
    require_uppercase                = true
    temporary_password_validity_days = 7 

  }

  verification_message_template = {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  domain_certificate_arn = local.certificate_arn

  # user_pool_domain
  domain = "auth.${var.domain}"

  admin_create_user_config = {
    allow_admin_create_user_only=false

  }

  string_schemas = [
    {
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true 
      name                     = "email"
      required                 = true

      string_attribute_constraints = {
        min_length = 0
        max_length = 2048
      }
    }
  ]

  # clients
  clients = [
    {
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = ["email", "openid"]
      callback_urls = var.environment == "prod" ? ["https://${var.domain}/"] : ["https://${var.domain}/","http://localhost:3000/"]
      default_redirect_uri                 = "https://${var.domain}/"
      #explicit_auth_flows                  = ["CUSTOM_AUTH_FLOW_ONLY", "ADMIN_NO_SRP_AUTH"]
      generate_secret                      = false
      logout_urls                          = var.environment == "prod" ? ["https://${var.domain}/"] : ["https://${var.domain}/","http://localhost:3000/"]

      name                                 = "${var.app}-${var.environment}-user-pool-client"
      refresh_token_validity               = 30
      supported_identity_providers         = ["Google","COGNITO"]
    },
    {
      allowed_oauth_flows                  = ["code"]
      allowed_oauth_flows_user_pool_client = true
      allowed_oauth_scopes                 = ["email", "openid"]
      callback_urls = var.environment == "prod" ? ["https://${var.domain}/"] : ["https://${var.domain}/","http://localhost:3000/"]
      default_redirect_uri                 = "https://${var.domain}/"
      #explicit_auth_flows                  = ["CUSTOM_AUTH_FLOW_ONLY", "ADMIN_NO_SRP_AUTH"]
      generate_secret                      = false
      logout_urls                          = var.environment == "prod" ? ["https://${var.domain}/"] : ["https://${var.domain}/","http://localhost:3000/"]

      name                                 = "${var.app}-${var.environment}-user-pool-client"
      read_attributes                      = ["email"]
      refresh_token_validity               = 30
    }
  ]

  # tags
  tags = var.tags
}


resource "aws_cognito_identity_provider" "social_provider" {
  user_pool_id  = module.aws_cognito_user_pool.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.google_client_id 
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.app}-${var.environment}-identity-pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = module.aws_cognito_user_pool.client_ids[0]
    provider_name           = "cognito-idp.ap-northeast-1.amazonaws.com/${module.aws_cognito_user_pool.id}"
    server_side_token_check = false
  }
}

output "id" {
  value = module.aws_cognito_user_pool.id
}

output "client_ids" {
  value = module.aws_cognito_user_pool.client_ids
}

