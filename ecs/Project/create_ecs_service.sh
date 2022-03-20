#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/ecs_functions.sh

SVC_TD_NAME=$1
export TD_ARN=$(aws ecs list-task-definitions \
    --region ${region_name} | jq -r '.taskDefinitionArns[]' | grep ${SVC_TD_NAME} | tail -n1)
export TG_ARN=$(aws elbv2 describe-target-groups \
    --region $region_name | jq -r '.TargetGroups[].TargetGroupArn' | grep $SVC_TD_NAME)
export ECS_SVC_NAME=${SVC_TD_NAME}
export TG_CONTAINER=${SVC_TD_NAME}
export SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --region ${region_name} \
    --filters Name=group-name,Values=*${ecs_sg_name}* \
    --query "SecurityGroups[*].{ID:GroupId}" \
    --output text)

create_ecs_svc ${region_name} ${cluster_name} ${ECS_SVC_NAME} ${ecs_svc_temp_file_output}


# Create a ECS Service and specifying a Capacity Provider:
# aws ecs create-service \
#     --cluster $cluster_name \
#     --service-name $service_name \
#     --task-definition mytaskdef:1 \
#     --desired-count 1 \
#     --scheduling-strategy "REPLICA" \
#     --capacity-provider-strategy='[{"capacityProvider": "ondemand-capacity","weight": 0, "base": 1},{"capacityProvider": "spot-capacity", "weight": 100, "base": 0}]'

# Update ECS Service to the latest task definition revision:
# aws ecs update-service \
#     --cluster $cluster_name \
#     --service $service_name \
#     --task-definition $task_def

# Update ECS Service to 3 replicas:
# aws ecs update-service \
#     --cluster $cluster_name \
#     --service $service_name \
#     --desired-count 3

# Update ECS Service to use Capacity Providers:
# aws ecs update-service --cluster $cluster_name \
#     --service $service_name \
#     --capacity-provider-strategy='[{"capacityProvider": "ondemand-capacity", "weight": 0, "base": 1},{"capacityProvider": "spot-capacity", "weight": 100, "base": 0}]' \
#     --force-new-deployment
