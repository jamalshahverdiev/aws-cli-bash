#!/usr/bin/env bash
. ./libs/ecr_functions.sh

all_repo_names='''
project-authdata-prod
project-authdata-sandbox
project-front1-prod
project-front1-sandbox
project-front2-prod
project-front2-sandbox
project-site-prod
project-site-sandbox
'''

for repo in ${all_repo_names}; do
    svc_name=$(echo ${repo} | awk -F'-' '{print $2}')
    env_name=$(echo ${repo} | awk -F'-' '{print $3}')
    create_aws_ecs_registry ${svc_name} ${env_name} 
    # delete_aws_ecr_registry ${svc_name} ${env_name}
done

list_aws_ecr_repo_names