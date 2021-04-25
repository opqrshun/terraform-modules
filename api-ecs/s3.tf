resource "aws_s3_bucket" "bucket" {
  bucket = "${local.namespace}-log-s3"
  acl    = "private"
}


#resource "aws_s3_access_point" "ap" {
#  bucket = aws_s3_bucket.bucket.id
#  name   = "${local.namespace}-log-s3-ap"
#
#  # VPC must be specified for S3 on Outposts
#  vpc_configuration {
#    vpc_id = local.vpc_id 
#  }
#}
