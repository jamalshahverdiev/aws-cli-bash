#!/usr/bin/env bash

create_ecs_iam_roles() {
    create_iam_role_result=$(aws cloudformation create-stack --stack-name "${project_name}-iam" \
        --capabilities CAPABILITY_IAM \
        --template-body file://./${iam_stack_file} \
        --region ${region_name})
    
    echo ${create_iam_role_result} 

    while [ $(aws cloudformation describe-stacks --stack-name ${project_name}-iam --region ${region_name} | jq -r '.Stacks[].StackStatus') == 'CREATE_IN_PROGRESS' ]; do
        echo "ECS IAM stack ${project_name}-iam still creating"
        sleep 5
    done
}

create_task_definition_iam_role() {
    create_iam_role_result=$(aws iam create-role --role-name ${task_exec_role_name} \
        --assume-role-policy-document file://./${task_exec_assume_role_json_file}) && echo ${create_iam_role_result}

    create_policy_for_ssm_params=$(aws iam create-policy \
        --policy-name ${ssm_parameters_policy_name} \
        --policy-document file://./${get_ssm_parameters_json_file}) && echo ${create_policy_for_ssm_params}

    aws_policies_object=$(aws iam list-policies)

    for policy_name in ${policy_names}; do
        arn_of_policy=$(echo $aws_policies_object | jq -r '.Policies[]|select(.PolicyName=="'${policy_name}'").Arn')
        result_of_attach=$(aws iam attach-role-policy \
            --policy-arn ${arn_of_policy} \
            --role-name ${task_exec_role_name})
        echo ${result_of_attach}
    done
}

create_policies(){
    if [[ $# != 1 ]]; then echo "Usage: ./$(basename $0) policy_name"; exit 32; fi
    policy_name=$1
    create_new_policy_result=$(aws iam create-policy \
        --policy-name ${policy_name} \
        --policy-document file://./yaml_json/${policy_name}.json)
    echo $create_new_policy_result
}

create_iam_user(){
    if [[ $# != 2 ]]; then echo "Usage: ./$(basename $0) iam_user_name arn_of_policy"; exit 32; fi
    iam_user_name=$1
    arn_of_policy=$2
    aws_iam_users=$(aws iam list-users | jq -r '.Users[].UserName')
    if [[ ! "$aws_iam_users" =~ .*"$iam_user_name".* ]]; then
        create_iam_user_result=$(aws iam create-user --user-name ${iam_user_name} \
            --tags '{"Key": "Name", "Value": "'"${iam_user_name}"'"}')
        echo ${create_iam_user_result}
        result_of_create_iam_user=$(aws iam create-access-key --user-name ${iam_user_name})
        user_access_key=$(echo ${result_of_create_iam_user} | jq '.AccessKey.AccessKeyId')
        user_secret_key=$(echo ${result_of_create_iam_user} | jq '.AccessKey.SecretAccessKey')
        echo "Username: ${iam_user_name} || Access_KEY_ID: ${user_access_key} || Secret_Access_Key: ${user_secret_key}"
    fi
    attach_iam_user_policy_result=$(aws iam attach-user-policy \
        --policy-arn ${arn_of_policy} \
        --user-name ${iam_user_name})
    echo ${attach_iam_user_policy_result}
}