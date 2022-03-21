#!/usr/bin/env bash
. ./libs/variables.sh

security_group_names=$(cat create_security_groups.sh| grep _RDS_)
rds_sg_name=$(echo $security_group_names | awk '{ print $1}' | head -n1 | awk -F':' '{ print $1}')
rds_sg_name_reserved=$(echo $security_group_names | awk '{ print $2}' | tail -n1 | awk -F':' '{ print $1}')
rds_sg_id=$(aws ec2 describe-security-groups \
    --region ${region_name} \
    --filters Name=group-name,Values=*${rds_sg_name}* \
    --query "SecurityGroups[*].{ID:GroupId}" --output text)
rds_sg_id_reserved=$(aws ec2 describe-security-groups \
    --region ${region_name} \
    --filters Name=group-name,Values=*${rds_sg_name_reserved}* \
    --query "SecurityGroups[*].{ID:GroupId}" --output text)

aws rds create-db-subnet-group \
    --db-subnet-group-name ${db_subnet_group_name} \
    --db-subnet-group-description "Payriff DB subnet group" \
    --region ${region_name} \
    --subnet-ids ${subnet_pr_1} ${subnet_pr_2} ${subnet_pr_3}

aws rds create-db-instance --db-name ${db_name} \
    --db-instance-identifier ${db_name} \
    --allocated-storage 100 \
    --db-instance-class ${instance_type} \
    --engine postgres \
    --master-username ${master_username} \
    --master-user-password ${master_password} \
    --vpc-security-group-ids ${rds_sg_id} ${rds_sg_id_reserved} \
    --db-subnet-group-name ${db_subnet_group_name} \
    --port 5432
    # --availability-zone ap-south-1c ap-south-1b ap-south-1a \
    # --db-subnet-group rds_sg_id \
    # --publicly-accessible \


## Delete RDS
# aws rds delete-db-instance \
#     --db-instance-identifier mydatahackpgres \
#     --skip-final-snapshot
