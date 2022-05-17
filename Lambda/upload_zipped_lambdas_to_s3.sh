#!/usr/bin/env bash

get_all_lambda_json_object=$(aws lambda list-functions | jq '.Functions[]')
function_names=$(echo $get_all_lambda_json_object| jq -r '.FunctionName')
bucket_name='bucket_name'
folder_in_bucket='lambda_functions'

for function_name in $function_names; do
    prog_lang=$(echo $get_all_lambda_json_object | jq -r 'select(.FunctionName=="'$function_name'").Runtime')
    if [[ $prog_lang == *"nodejs"* ]]
    then 
        extension='js'
    elif [[ $prog_lang =~ "python" ]]; then
        extension='py'
    fi
    code_location=$(aws lambda get-function --function-name ${function_name} | jq -r '.Code.Location')
    wget -O ${function_name}.${extension}.zip $code_location
    aws s3 cp ${function_name}.${extension}.zip s3://${bucket_name}/${folder_in_bucket}/
done