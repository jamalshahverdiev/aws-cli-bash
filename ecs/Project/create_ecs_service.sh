#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/ecs_functions.sh

service_names='''
sandbox-website
sandbox-pay
sandbox-dashboard
sandbox-core
'''

for svc_in_ecs in ${service_names}; do
    create_ecs_svc ${region_name} ${cluster_name} ${svc_in_ecs} ${ecs_svc_temp_file_output}
done

# Get names of all services
# aws ecs list-services \
#   --cluster $cluster_name \
#   --region ${region_name} | jq -r '.serviceArns[]' | awk -F'/' '{ print $(NF)}'

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
