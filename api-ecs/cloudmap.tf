resource "aws_service_discovery_http_namespace" "main" {
  name = "${local.namespace}-namespace"
  description = ""
}

resource "aws_service_discovery_service" "main" {
  name = "${local.namespace}-service"
  namespace_id = aws_service_discovery_http_namespace.main.id
}

resource "aws_service_discovery_instance" "main" {
  instance_id = "${local.namespace}-instance-1"
  service_id  = aws_service_discovery_service.main.id

  attributes = {
    AWS_INSTANCE_IPV4 = var.service_instance_ip 
    AWS_INSTANCE_PORT = 8080
  }
}
