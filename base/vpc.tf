module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.app}-${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}${var.availability_zones[0]}", "${var.region}${var.availability_zones[1]}", "${var.region}${var.availability_zones[2]}"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  create_igw=true

  tags = var.tags
}
