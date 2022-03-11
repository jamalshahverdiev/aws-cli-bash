#!/usr/bin/env bash


create_update_ecs_cluster(){
    cluster_name="$project_name-pk"
    get_stack_name=$(aws cloudformation describe-stacks --region ${region_name} \
        --stack-name amazon-ecs-cli-setup-${cluster_name} | jq -r '.Stacks[].StackName')
    if [[ ${get_stack_name} != "amazon-ecs-cli-setup-${cluster_name}" ]]; then
        create_ecs_result=$(ecs-cli up --region ${region_name} \
                --subnets $subnet_pr_1,$subnet_pr_2,$subnet_pr_3 \
                --vpc $vpc_id --launch-type FARGATE --cluster ${cluster_name})
        echo ${create_ecs_result}

        while [ $(aws ecs describe-clusters --cluster $project_name-pk --region ${region_name} | jq -r '.clusters[].status') == 'INACTIVE' ]; do
            echo "ECS Cluster ${cluster_name} still creating!"
            sleep 5
        done

        update_ecs_cluster_result=$(aws ecs update-cluster-settings --cluster ${cluster_name} \
            --region ${region_name} \
            --settings name=containerInsights,value=enabled)
        echo ${update_ecs_cluster_result}

        update_ecs_capacity_result=$(aws ecs put-cluster-capacity-providers --cluster ${cluster_name} \
            --capacity-providers FARGATE_SPOT FARGATE \
            --default-capacity-provider-strategy capacityProvider=FARGATE \
            --region ${region_name})

        echo ${update_ecs_capacity_result}
    fi
}

create_ecs_svc() {
    if [[ $# != 4 ]]; then echo "Usage: ./$(basename $0) region_name cluster_name ecs_svc_name ecs_svc_temp_file_output"; exit 23; fi
    region_name=$1
    cluster_name=$2
    ecs_svc_name=$3
    ecs_svc_temp_file_output=$4
    cat ${ecs_svc_temp_file} | envsubst > ${ecs_svc_temp_file_output}
    create_svc_result=$(aws ecs create-service \
        --region ${region_name} \
        --cluster ${cluster_name} \
        --service-name ${ecs_svc_name} \
        --cli-input-json file://./${ecs_svc_temp_file_output})
    echo ${create_svc_result}
}