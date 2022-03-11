Launchtype _Fargate_:  

```bash
aws cloudformation create-stack --stack-name ecs-fargate --capabilities CAPABILITY_IAM --template-body file://./ecs-fargate-via-cloudformation.yml
```


## create ecs cluster with launch-type FARGATE

```bash
ecs-cli up \
--subnets $subnet_1,$subnet_2 \
--vpc $vpc \
--launch-type FARGATE \
--cluster payriff-pk
```