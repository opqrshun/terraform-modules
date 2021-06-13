################################################################################
# RDS Module
################################################################################

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "./../../../base/envs/dev/terraform.tfstate"
  }
}

locals {
  vpc_id          = data.terraform_remote_state.base.outputs.vpc_id
  vpc_cidr_block  = data.terraform_remote_state.base.outputs.vpc_cidr_block
  private_subnets = data.terraform_remote_state.base.outputs.private_subnets
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3"

  name        = "${var.app}-${var.environment}-rds-sg"
  description = "RDS Security Group"
  vpc_id      = local.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = local.vpc_cidr_block
    },
  ]

  tags = var.tags
}

#resource "random_password" "password" {
#  length           = 10
#  special          = true
#  override_special = "_%@"
#}

module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "${var.app}-${var.environment}-mariadb"

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mariadb"
  engine_version       = "10.5.8"
  
  # 必須 Option group properties
  major_engine_version     = "10.5"

  # 必須 parameter group family
  family = "mariadb10.5"

  # create parameter group
  parameter_group_name = "${var.app}-${var.environment}-pg"

  instance_class       = "db.t2.micro"

  #  DB Instance class db.t2.micro does not support encryption
  storage_encrypted     = false 
  # DB Storage GB
  allocated_storage = 20

  # create db
  # only alphanumeric characters
  name     = "${var.app}${var.environment}"
  username = "${var.app}${var.environment}"
  password = var.rds_password 
  port     = 3306

  # not free
  multi_az               = false 

  subnet_ids             = local.private_subnets
  vpc_security_group_ids = [module.security_group.this_security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["general"]

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = var.deletion_protection

  # mariadb not supported
  # performance_insights_enabled          = true
  # performance_insights_retention_period = 7

  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name = "${var.app}-${var.environment}-monitoring-rds-role"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = var.tags
  db_instance_tags = var.tags
  db_option_group_tags = var.tags
  db_subnet_group_tags = var.tags

}

