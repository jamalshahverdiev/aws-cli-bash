#!/usr/bin/env bash

create_ssm_parameters(){
    if [[ $# != 2 ]]; then echo "Usage: ./$(basename $0) param_name param_value"; exit 71; fi
    param_name=$1
    param_value=$2
    if [[ ! "$ssm_parameters" =~ .*"$param_name".* ]]; then
        echo "Created SSM parameter: ${param_name}"
        ssm_param_result=$(aws ssm put-parameter \
            --name "${param_name}" \
            --value "${param_value}" \
            --type "SecureString" \
            --region ${region_name})
        echo $ssm_param_result
    else
        echo "Entered SSM parameter ${param_name} present in this region!"
    fi
}

delete_all_ssm_parameters() {
    for ssm_parameter in ${ssm_parameters}; do
        aws ssm delete-parameter --region ${region_name} --name ${ssm_parameter}
    done
}