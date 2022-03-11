#!/usr/bin/env bash
. ./libs/variables.sh

aws rds create-db-subnet-group \
    --db-subnet-group-name ${db_subnet_group_name} \
    --db-subnet-group-description "Project DB subnet group" \
    --region ${region_name} \
    --subnet-ids ${subnet_pr_1} ${subnet_pr_2} ${subnet_pr_3}

aws rds create-db-instance --db-name ${db_name} \
    --db-instance-identifier ${db_name} \
    --allocated-storage 100 \
    --db-instance-class ${instance_type} \
    --engine postgres \
    --master-username ${master_username} \
    --master-user-password ${master_password} \
    --vpc-security-group-ids ${vpc_sg_id} ${vpc_sg_id_reserved} \
    --db-subnet-group-name ${db_subnet_group_name} \
    --port 5432

## Delete RDS
# aws rds delete-db-instance \
#     --db-instance-identifier mydatahackpgres \
#     --skip-final-snapshot