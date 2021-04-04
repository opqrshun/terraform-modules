module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"

  name          = "${var.app}-${var.environment}-http-api"
  description   = "allows public API Gateway for ${local.namespace} to talk to private NLB"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  domain_name              = "api.${var.domain}"
  domain_name_certificate_arn = local.certificate_arn


  integrations = {
#    "ANY /" = {
#      lambda_arn             = module.lambda_function.this_lambda_function_arn
#      payload_format_version = "2.0"
#      timeout_milliseconds   = 12000
#    }

    "ANY /" = {
      connection_type    = "VPC_LINK"
      vpc_link          = "my-vpc"
      integration_uri    = aws_lb_listener.tcp.arn
      
      # vpc link HTTP_PROXY
      integration_type   = "HTTP_PROXY"
      integration_method = "ANY"
    }
  }

  vpc_links = {
    my-vpc = {
      name               = "${var.app}-${var.environment}-vpc-link"
      security_group_ids = [module.api_gateway_security_group.this_security_group_id]
      subnet_ids         = local.target_subnets
    }
  }

  tags = var.tags

}

module "api_gateway_security_group" {
  source  = "terraform-aws-modules/security-group/aws"

  name          = "${var.app}-${var.environment}-api-gateway-sg"
  description = "Security group for VPC link"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]
}


