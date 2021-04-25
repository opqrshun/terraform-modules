locals {
  # KMS write actions
  kms_write_actions = [
    "kms:CancelKeyDeletion",
    "kms:CreateAlias",
    "kms:CreateGrant",
    "kms:CreateKey",
    "kms:DeleteAlias",
    "kms:DeleteImportedKeyMaterial",
    "kms:DisableKey",
    "kms:DisableKeyRotation",
    "kms:EnableKey",
    "kms:EnableKeyRotation",
    "kms:Encrypt",
    "kms:GenerateDataKey",
    "kms:GenerateDataKeyWithoutPlaintext",
    "kms:GenerateRandom",
    "kms:GetKeyPolicy",
    "kms:GetKeyRotationStatus",
    "kms:GetParametersForImport",
    "kms:ImportKeyMaterial",
    "kms:PutKeyPolicy",
    "kms:ReEncryptFrom",
    "kms:ReEncryptTo",
    "kms:RetireGrant",
    "kms:RevokeGrant",
    "kms:ScheduleKeyDeletion",
    "kms:TagResource",
    "kms:UntagResource",
    "kms:UpdateAlias",
    "kms:UpdateKeyDescription",
  ]

  # KMS read actions
  kms_read_actions = [
    "kms:Decrypt",
    "kms:DescribeKey",
    "kms:List*",
  ]
}


# kms key used to encrypt ssm parameters
resource "aws_kms_key" "ssm" {
  description             = "ssm parameters key for ${var.app}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = var.tags
  #policy                  = data.aws_iam_policy_document.ssm.json
}

resource "aws_kms_alias" "ssm" {
  name          = "alias/${var.app}-${var.environment}-kms"
  target_key_id = aws_kms_key.ssm.id
}


# allow ecs task execution role to read this app's parameters
resource "aws_iam_policy" "ecsTaskExecutionRole_ssm" {
  name        = "${var.app}-${var.environment}-ecs-ssm"
  path        = "/"
  description = "allow ecs task execution role to read this app's parameters"

# TODO resource
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters"
      ],
      "Resource": "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.app}/${var.environment}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${aws_kms_key.ssm.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_ssm" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = aws_iam_policy.ecsTaskExecutionRole_ssm.arn
}

output "ssm_add_secret" {
  value = "aws ssm put-parameter --overwrite --type \"SecureString\" --key-id \"${aws_kms_alias.ssm.name}\" --name \"/${var.app}/${var.environment}/PASSWORD\" --value \"password\""
}

output "ssm_add_secret_ref" {
  value = "fargate service env set --secret PASSWORD=/${var.app}/${var.environment}/PASSWORD"
}

output "ssm_key_id" {
  value = aws_kms_key.ssm.key_id
}
