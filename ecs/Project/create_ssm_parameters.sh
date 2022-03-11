#!/usr/bin/env bash

. ./libs/ssm_functions.sh
. ./libs/variables.sh

ssm_parameters_list='''
PROD_AUTHDATA_DB_PASS=zdkjfhsdkjfdshfkjsdhk
PROD_AUTHDATA_DB_URL=jdbc:postgresql://database.domain.name:5432/project_db
PROD_AUTHDATA_DB_USER=project_user
PROD_AUTHDATA_S3_ACCESS=HDKJAHDKJAHDLKAHLDKHKL
PROD_AUTHDATA_S3_SECRET=KLJLJLKJLKJDLKSJDKLJDLKAJDLKAJDLKA
SANDBOX_AUTHDATA_DB_PASS=LKDKSJSLKDJSLKDJLSKDJLS
SANDBOX_AUTHDATA_DB_URL=jdbc:postgresql://database.domain.name:5432/sandbox_project_db
SANDBOX_AUTHDATA_DB_USER=sandbox_project_user
SANDBOX_AUTHDATA_S3_ACCESS=KDJHJKDHSJKDHSKDJHSJKDSHK
SANDBOX_AUTHDATA_S3_SECRET=LKDSKHDKJSHDKJSDHSKJDHSKJDHSKJDHSKJD
'''

for ssm_param in ${ssm_parameters_list}; do
    param_name=$(echo $ssm_param|awk -F'=' '{print $1}')
    param_value=$(echo $ssm_param|awk -F'=' '{print $2}')
    create_ssm_parameters ${param_name} ${param_value}
done

# delete_all_ssm_parameters
