# Deployment of ECS environment

#### Create IAM `roles`, `policies` and `Users`

```bash
$ ./create_iam_user_role_policy.sh
```

#### Create `VPC`, `Subnets`, `NAT gateways` and `Internet gateway`. Create `ECS` cluster.

```bash
$ ./create_vpc_ecs.sh
```

#### Create `Security groups`, `SSM parameters`, `Docker registry endpoints` and `Loggroups` in Cloudwatch

```bash
$ ./create_security_groups.sh
$ ./create_ssm_parameters.sh
$ ./ecs_docker_registry.sh
$ ./create_log_groups.sh
```


#### Create `ALB` and and `RDS` 

```bash
$ ./create_albv2.sh
$ ./create_rds.sh
```

#### To create ECS service we can use the followng script

```bash
$ create_ecs_service.sh
```

Launchtype _Fargate_:  

```bash
$ aws cloudformation create-stack --stack-name ecs-fargate --capabilities CAPABILITY_IAM --template-body file://./ecs-fargate-via-cloudformation.yml
```
