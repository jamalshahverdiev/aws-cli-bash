#!/usr/bin/env bash
. ./libs/variables.sh
. ./libs/sg_functions.sh 
security_group_lines='''
project-rds-sg:Allow_RDS_connection_from_ECS_VPC
project-rds-reserved-sg:Allow_access_to_RDS_reserved
project-ecs-alb-access:Allow_access_to_loadbalancers_from_outside
ssh-access:ssh-access
gitlab-docker-runner-sg:gitlab-docker-runner-sg
project-svc-sg:Allow_80_and_8080
'''

for security_group_line in ${security_group_lines}; do
    sg_name=$(echo ${security_group_line} | awk -F ':' '{ print $1}')
    sg_desc=$(echo ${security_group_line} | awk -F ':' '{ print $2}')
    create_security_groups ${sg_name} ${sg_desc} && sleep 3
    if [[ ${sg_name} == 'project-svc-sg' ]]; then
        declare -A SVCMAP=( [80]=0.0.0.0/0 [8080]=0.0.0.0/0 )
        for key in "${!SVCMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${SVCMAP[$key]} ${region_name}
        done
    elif [[ ${sg_name} == 'gitlab-docker-runner-sg' ]]; then
        declare -A GITMAP=( [2376]=10.0.0.0/16 [22]=0.0.0.0/0 )
        for key in "${!GITMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${GITMAP[$key]} ${region_name}
        done 
    elif [[ ${sg_name} == 'ssh-access' ]]; then 
        declare -A SSHMAP=( [22]=0.0.0.0/0 )
        for key in "${!SSHMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${SSHMAP[$key]} ${region_name}
        done       
    elif [[ ${sg_name} == 'project-ecs-alb-access' ]]; then 
        declare -A ALBMAP=( [80]=0.0.0.0/0 [443]=0.0.0.0/0 )
        for key in "${!ALBMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${ALBMAP[$key]} ${region_name}
        done 
    elif [[ ${sg_name} == 'project-rds-reserved-sg' ]]; then 
        declare -A PGMAP=( [5432]=10.0.0.0/16 )
        for key in "${!PGMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${PGMAP[$key]} ${region_name}
        done 
    elif [[ ${sg_name} == 'project-rds-sg' ]]; then 
        declare -A PGRMAP=( [5432]=0.0.0.0/0 )
        for key in "${!PGRMAP[@]}"; do
            add_rule_to_sg $sg_name 'tcp' $key ${PGRMAP[$key]} ${region_name}
        done 
    fi
done


    
