
### Run first  
Setup Zone, ACM, ECR ,VPC

```
cd base/envs/dev/
terraform init
terraform apply -var-file ../../../dev.tfvars

```

### Set up ECS with API Gateway

```
cd api-ecs/envs/dev/
terraform init
terraform apply -var-file ../../../dev.tfvars

```

### When hosting on S3 with Cloudfront

```
cd cdn-s3/envs/dev/
terraform init
terraform apply -var-file ../../../dev.tfvars

```


### When use RDS

```
cd rds/envs/dev/
terraform init
terraform apply -var-file ../../../dev.tfvars

```


### When use EC2

```
cd ec2/envs/dev/
terraform init
terraform apply -var-file ../../../dev.tfvars

```

## Clean up


```
# In each directory
terraform destroy -var-file ../../../dev.tfvars

```



