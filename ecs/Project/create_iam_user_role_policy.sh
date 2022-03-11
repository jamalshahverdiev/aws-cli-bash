#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/iam_functions.sh

create_task_definition_iam_role

for policy_name in ${project_iam_policies}; do create_policies ${policy_name}; done

aws_policies_object=$(aws iam list-policies)
for policy_name in ${gitlab_user_policies}; do
    arn_of_policy=$(echo $aws_policies_object | jq -r '.Policies[]|select(.PolicyName=="'${policy_name}'").Arn')
    create_iam_user 'some_user_name' $arn_of_policy
done

aws_policies_object=$(aws iam list-policies)
for iam_user_from_array in "${!iam_user_array[@]}"; do
    for policy_of_iam_user in ${iam_user_array[$iam_user_from_array]}; do
        arn_of_policy=$(echo $aws_policies_object | jq -r '.Policies[]|select(.PolicyName=="'${policy_of_iam_user}'").Arn')
        create_iam_user $iam_user_from_array $arn_of_policy
    done
done 