#!/usr/bin/env bash

project_name='project'
export cluster_name="$project_name-cluster"
region_name='us-east-1'
task_exec_role_name='ecsTaskExecutionRole'
db_name='projectdbmaster'
db_subnet_group_name='project-db-sgr'
instance_type='db.m5.xlarge'
master_username='projectdbmaster'
master_password='KFJSHLKSFHLKSFHSLKHFLKSFHLKSFHSL'
vpc_sg_id='sg-idfisdfsdfsdlfjsdf'
vpc_sg_id_reserved='sg-sdfsdfsdfsdfsd'
### Must change to be dynamically
albv2_name='project-ecs-alb-access'
alb_sg_id=$(aws ec2 describe-security-groups \
    --region ${region_name} | jq -r '.SecurityGroups[]|select(.GroupName=="'${albv2_name}'").GroupId')
net_stack_file='yaml_json/setup-infrastructure.yaml'
iam_stack_file='yaml_json/create-iam-roles.yaml'
ecs_svc_temp_file='yaml_json/ecs_create_service.json'
ecs_svc_temp_file_output='yaml_json/ecs_create_service_output.json'
task_exec_assume_role_json_file='yaml_json/ecs_task_exec_role_trust_relationship.json'
get_ssm_parameters_json_file='yaml_json/get_ssm_parameters.json'
ecs_sg_name='payriff-svc-sg'
ssm_parameters_policy_name='GetSSMParameters'
ssm_parameters=$(aws ssm describe-parameters --region ${region_name} | jq -r '.Parameters[].Name')

network_all_outputs=$(aws cloudformation describe-stacks \
    --stack-name ${project_name}-network \
    --region ${region_name} \
    --query 'Stacks[].Outputs' \
    | jq '.[]')

vpc_id=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="VpcId").OutputValue')
# For Private
export subnet_pr_1=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PrivateSubnetOne").OutputValue')
export subnet_pr_2=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PrivateSubnetTwo").OutputValue')
export subnet_pr_3=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PrivateSubnetThree").OutputValue')

# For PUBLIC
subnet_pub_1=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PublicSubnetOne").OutputValue')
subnet_pub_2=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PublicSubnetTwo").OutputValue')
subnet_pub_3=$(echo $network_all_outputs | jq -r '.[]|select(.OutputKey=="PublicSubnetThree").OutputValue')


# IAM Variables
policy_names='''
AmazonECSTaskExecutionRolePolicy
AWSAppMeshEnvoyAccess
CloudWatchAgentServerPolicy
GetSSMParameters
AmazonS3FullAccess
'''

project_iam_policies='''
ProdProjectAuthDataS3Policy
SandboxProjectAuthDataS3Policy
'''

log_group_names='''
/ecs/project-prod-authdata
/ecs/project-prod-front1
/ecs/project-prod-front2
/ecs/project-prod-site
/ecs/project-sandbox-authdata
/ecs/project-sandbox-front1
/ecs/project-sandbox-front2
/ecs/project-sandbox-site
'''

declare -A iam_user_array=( [gitlab-docker-runner]="AmazonEC2FullAccess AmazonS3FullAccess" [prod_s3]="ProdProjectAuthDataS3Policy" [sandbox_s3]="SandboxProjectAuthDataS3Policy" [jamal]="AdministratorAccess AmazonECS_FullAccess" [gitlab-ci-jobs]="AdministratorAccess AmazonECS_FullAccess" )
