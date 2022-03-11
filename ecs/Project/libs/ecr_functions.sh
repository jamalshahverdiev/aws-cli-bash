#!/usr/bin/env bash

create_aws_ecs_registry() {
    if [[ $# != 2 ]]; then echo "Usage: ./$(basename $0) registry_name env_name(sandbox/prod)"; exit 64; fi
    registry_name=$1
    env_name=$2
    # region_name=$3
    result_of_create_registry=$(aws ecr create-repository \
        --repository-name payriff-${registry_name}-${env_name} \
        --region ${region_name} \
        --tags '[{"Key":"Name","Value": "'"${env_name}"'"},{"Key":"Company","Value":"ABHI"}]')
    # echo $result_of_create_registry
}

delete_aws_ecr_registry() {
    if [[ $# != 2 ]]; then echo "Usage: ./$(basename $0) registry_name env_name(sandbox/prod)"; exit 65; fi
    registry_name=$1
    env_name=$2
    result_of_delete_registry=$(aws ecr delete-repository \
            --repository-name payriff-${registry_name}-${env_name} \
            --region ${region_name} \
            --force)
}

list_aws_ecr_repo_names() {
    aws ecr describe-repositories | jq -r '.repositories[].repositoryUri'
}