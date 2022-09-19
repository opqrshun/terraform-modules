# creates an application role that the container/task runs as
# set assume_role_policy
# app_role_assume_role_policy(aws_iam_policy_document)
resource "aws_iam_role" "app_role" {
  name               = "${var.app}-${var.environment}-ecs_task-role"
  assume_role_policy = data.aws_iam_policy_document.app_role_assume_role_policy.json
}

# assigns the app policy
# aws_iam_role and app_policy(aws_iam_policy_document)
resource "aws_iam_role_policy" "app_policy" {
  name   = "${var.app}-${var.environment}-ecs-policy"
  role   = aws_iam_role.app_role.id
  policy = data.aws_iam_policy_document.app_policy.json
}

# TODO: fill out custom policy
data "aws_iam_policy_document" "app_policy" {
  statement {
    actions = [
      "ecs:DescribeClusters",
    ]

    resources = [
      aws_ecs_cluster.app.arn,
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-log-s3/*",
      "arn:aws:s3:::${var.app}-${var.environment}-deleted-files/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.app}-${var.environment}-public-files-origin/*",
    ]
  }
}

data "aws_caller_identity" "current" {
}

# allow role to be assumed by ecs and local saml users (for development)
data "aws_iam_policy_document" "app_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com", "ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.app}-${var.environment}-ecs_task-role"
  role = aws_iam_role.app_role.name
}
