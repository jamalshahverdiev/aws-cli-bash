#!/usr/bin/env bash

create_pvc(){
    create_vpc_stack_result=$(aws cloudformation create-stack --stack-name "${project_name}-network" \
            --capabilities CAPABILITY_IAM \
            --template-body file://./${net_stack_file} \
            --region ${region_name})
    echo ${create_vpc_stack_result}

    while [ $(aws cloudformation describe-stacks --stack-name ${project_name}-network --region ${region_name} | jq -r '.Stacks[].StackStatus') == 'CREATE_IN_PROGRESS' ]; do
        echo "VPC stack ${project_name}-network still creating"
        sleep 5
    done
}

