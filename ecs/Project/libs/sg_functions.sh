#!/usr/bin/env bash

create_security_groups() {
    if [[ $# != 2 ]]; then echo "Usage: ./$(basename $0) sg_name sg_description"; exit 54; fi
    sg_name=$1
    sg_desc=$2
    create_sg_result=$(aws ec2 create-security-group \
        --group-name ${sg_name} \
        --description "${sg_desc}" \
        --vpc-id ${vpc_id} \
        --tag-specifications 'ResourceType=security-group,Tags=[{Key=Name,Value="'"${sg_name}"'"}]' \
        --region ${region_name})
    echo ${create_sg_result}
}

add_rule_to_sg() {
    if [[ $# != 5 ]]; then echo "Usage: ./$(basename $0) sg_name protocol port_number ip_and_range region_name"; exit 45; fi
    sg_name=$1
    protocol=$2
    port_number=$3
    ip_and_range=$4
    region_name=$5
    security_groups_object=$(aws ec2 describe-security-groups --region ${region_name})
    sg_id=$(echo $security_groups_object | jq -r '.SecurityGroups[]|select(.GroupName=="'$sg_name'").GroupId')
    add_rule_to_sg_result=$(aws ec2 authorize-security-group-ingress \
        --group-id ${sg_id} \
        --protocol ${protocol} \
        --port ${port_number} \
        --cidr $ip_and_range \
        --region ${region_name})
    echo $add_rule_to_sg_result
}
