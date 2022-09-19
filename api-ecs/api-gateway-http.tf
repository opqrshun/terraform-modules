module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.app}-${var.environment}-http-api"
  description   = "allows public API Gateway for ${local.namespace} to talk to private NLB"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = var.environment == "prod" ? ["https://${var.domain}"] : ["https://${var.domain}", "*"]
  }

  domain_name                 = "api.${var.domain}"
  domain_name_certificate_arn = local.certificate_arn


  integrations = {
    #    "ANY /" = {
    #      lambda_arn             = module.lambda_function.this_lambda_function_arn
    #      payload_format_version = "2.0"
    #      timeout_milliseconds   = 12000
    #    }

    #    "ANY /" = {
    #      connection_type    = "VPC_LINK"
    #      vpc_link          = "my-vpc"
    #      integration_uri    = aws_lb_listener.tcp.arn
    #      
    #      # vpc link HTTP_PROXY
    #      integration_type   = "HTTP_PROXY"
    #      integration_method = "ANY"
    #    }

    "GET /v1/user" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

    "GET /v1/user/{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

    "GET /{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

    }

    "PUT /{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

    "POST /{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

    "PATCH /{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

    "DELETE /{proxy+}" = {
      connection_type = "VPC_LINK"
      vpc_link        = "my-vpc"
      # integration_uri    = aws_lb_listener.tcp.arn
      integration_uri = aws_service_discovery_service.main.arn

      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"

      authorization_type = "JWT"
      authorizer_id      = aws_apigatewayv2_authorizer.authorizer.id
    }

  }

  vpc_links = {
    my-vpc = {
      name               = "${var.app}-${var.environment}-vpc-link"
      security_group_ids = [module.api_gateway_security_group.security_group_id]
      subnet_ids         = local.target_subnets
    }
  }

  tags = var.tags

}

resource "aws_apigatewayv2_stage" "example" {
  api_id      = module.api_gateway.apigatewayv2_api_id
  name        = "v1"
  auto_deploy = true
  tags        = var.tags
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.app}-${var.environment}-authorizer"

  jwt_configuration {
    audience = [var.api_audience]
    issuer   = var.api_issuer
  }
}

data "aws_route53_zone" "main" {
  name = var.zone
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${var.domain}"
  type    = "A"
  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

module "api_gateway_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.app}-${var.environment}-api-gateway-sg"
  description = "Security group for VPC link"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]
  tags         = var.tags
}


