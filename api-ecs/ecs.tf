resource "aws_ecs_cluster" "app" {
  name = "${var.app}-${var.environment}-cluster"
  tags = var.tags
}


resource "aws_appautoscaling_target" "app_scale_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = var.ecs_autoscale_max_instances
  min_capacity       = var.ecs_autoscale_min_instances
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # defined in role.tf
  task_role_arn = aws_iam_role.app_role.arn

  container_definitions = <<DEFINITION
[
  {
    "essential": true,
    "image": "public.ecr.aws/aws-observability/aws-for-fluent-bit:2.14.0",
    "name": "log_router",
    "firelensConfiguration": {
      "type": "fluentbit"
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/fargate/service/${var.app}-${var.environment}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "firelens"
      }
    },
    "memoryReservation": 128
  },
  {
    "name": "${var.app}-${var.environment}-app",
    "image": "${var.container_image}",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ],
    "essential": true,
    "environment" : [
    ],
    "secrets": [
      { "name" : "MYSQL_USER", "valueFrom" : "${local.ssm-namespace}/mysql_user" },
      { "name" : "MYSQL_DATABASE", "valueFrom" : "${local.ssm-namespace}/mysql_database" },
      { "name" : "MYSQL_PASSWORD", "valueFrom" : "${local.ssm-namespace}/mysql_password" },
      { "name" : "MYSQL_PROTOCOL", "valueFrom" : "${local.ssm-namespace}/mysql_protocol" },
      { "name" : "GEOCODING_API_KEY", "valueFrom" : "${local.ssm-namespace}/geocoding_api_key" },
      { "name" : "SENTRY_DSN", "valueFrom" : "${local.ssm-namespace}/sentry_dsn" },
      { "name" : "S3_BUCKET", "valueFrom" : "${local.ssm-namespace}/s3_bucket" },
      { "name" : "S3_DELETED_BUCKET", "valueFrom" : "${local.ssm-namespace}/s3_deleted_bucket" },
      { "name" : "S3_BUCKET_KEY", "valueFrom" : "${local.ssm-namespace}/s3_bucket_key" },
      { "name" : "S3_UPLOAD_TIMEOUT", "valueFrom" : "${local.ssm-namespace}/s3_upload_timeout" },
      { "name" : "CONTENT_IMAGE_BASE_URL", "valueFrom" : "${local.ssm-namespace}/content_image_base_url" },
      { "name" : "DELIVERY_URL", "valueFrom" : "${local.ssm-namespace}/delivery_url" },
      { "name" : "ENV", "valueFrom" : "${local.ssm-namespace}/env" },
      { "name" : "REGION", "valueFrom" : "${local.ssm-namespace}/region" }
    ],
    "logConfiguration": {
       "logDriver":"awsfirelens",
        "options": {
          "Name": "s3",
          "region": "${var.region}",
          "bucket": "${var.app}-${var.environment}-log-s3",
          "total_file_size": "1M",
          "upload_timeout": "1m",
          "use_put_object": "On"
        }
    },
    "memoryReservation": 256
  }
]
DEFINITION


  tags = var.tags
}

resource "aws_ecs_service" "app" {
  name            = "${var.app}-${var.environment}-service"
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.replicas

  network_configuration {
    security_groups = [aws_security_group.nsg_task.id]
    subnets  = local.target_subnets
    assign_public_ip = "${var.private == true ? false : true }"
  }

 # load_balancer {
 #   target_group_arn = aws_lb_target_group.main.id
 #   container_name   = local.container_name 
 #   container_port   = var.container_port
 # }

  tags                    = var.tags
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"

  # workaround for https://github.com/hashicorp/terraform/issues/12634

  # lbを使わないため Comment out
  # depends_on = [aws_lb_listener.tcp]

  # [after initial apply] don't override changes made to task_definition
  # from outside of terrraform (i.e.; fargate cli)
  lifecycle {
    ignore_changes = [task_definition]
  }
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app}-${var.environment}-ecs_task_execution-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }

}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

variable "logs_retention_in_days" {
  type        = number
  default     = 90
  description = "Specifies the number of days you want to retain log events"
}

resource "aws_cloudwatch_log_group" "logs" {
  name              = "/fargate/service/${var.app}-${var.environment}"
  retention_in_days = var.logs_retention_in_days
  tags              = var.tags
}

