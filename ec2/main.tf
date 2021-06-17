data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../../../base/envs/${var.environment}/terraform.tfstate"
  }
}

data "aws_internet_gateway" "igw" {
  internet_gateway_id = data.terraform_remote_state.base.outputs.igw_id
}

locals {
  vpc_id          = data.terraform_remote_state.base.outputs.vpc_id
  vpc_cidr_block  = data.terraform_remote_state.base.outputs.vpc_cidr_block
  public_subnets = data.terraform_remote_state.base.outputs.public_subnets
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "${var.app}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = local.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp","ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = var.tags
}

resource "aws_key_pair" "pair" {
  key_name   = "${var.app}-${var.environment}-key"
  public_key = var.public_key
  tags = var.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_kms_key" "this" {
  description       = "EC2 KMS key"
  tags = var.tags
}



module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  instance_count = 1

  name          = "${var.app}-${var.environment}-ec2"
  ami           = data.aws_ami.ubuntu.id
  # ami           = "ami-04cc2b0ad9e30a9c8"
  instance_type = "t2.micro"

  subnet_id     = tolist(local.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]

  associate_public_ip_address = true

  key_name = aws_key_pair.pair.key_name

  # AZ ?
  # https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/placement-groups.html
  # placement_group             = aws_placement_group.web.id

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp2"
      volume_size = 5
      encrypted   = true
      kms_key_id  = aws_kms_key.this.arn
    }
  ]

  tags = var.tags
}


resource "aws_eip" "eip" {
  vpc = true

  instance                  = module.ec2.id[0]
  depends_on                = [data.aws_internet_gateway.igw]

  tags = var.tags
}


output "eip" {
  value = aws_eip.eip.public_ip
}
