#!/usr/bin/env bash

usage() { 
    echo "Usage:   ./$(basename $0) file_path bucket_name" && exit 1
}

check_bucket_exists() {
    aws s3api head-bucket --bucket $bucket_name >/dev/null 2>&1
    if [ ${?} -eq 0 ]; then 
        echo "$bucket_name - named bucket exists"
    else 
        echo "$bucket_name - bucket doesn't exists" && aws s3 mb s3://$bucket_name
    fi
}

if_file_exists_in_bucket() {
    check_file_inside_bucket=$(aws s3api list-objects \
                                --bucket $bucket_name \
                                --query 'Contents[*].Key' \
                                --output yaml | grep -w $file_name | tr -d ' -' )
    echo $check_file_inside_bucket
    if [ "$check_file_inside_bucket" = "$file_name" ]; then
        echo '---------------------------'
	echo "$file_name exists in the bucket"
	exit 22
    else 
	echo "$file_name doesn't exists in the bucket and it will be copied"
        pushd $dir_path && aws s3 cp $file_name s3://$bucket_name/$file_name $option && popd 
    fi
}

execute_flow() {
    if [ -d "$file_path" ]; then
        option="--recursive"
        dir_path=$file_path
	
        echo "$file_path" | grep '/' > /dev/null
        if [[ $? == 0 ]]; then
            file_name=$(echo "$file_path" | awk -F '/' '{ print $(NF-1)}')
            dir_path=$(echo ${file_path} | sed  "s/${file_name}//")
        fi
        check_bucket_exists && if_file_exists_in_bucket
    elif [ -f "$file_path" ]; then
        option="" 
        dir_path='./'
        file_name=$file_path
	
        echo "$file_path" | grep '/' > /dev/null
        if [[ $? == 0 ]]; then
            file_name=$(echo "$file_path" | awk -F '/' '{ print $(NF)}') 
            dir_path=$(echo ${file_path} | sed  "s/${file_name}//")
        fi
        check_bucket_exists && if_file_exists_in_bucket
    else 
        echo "Entered file or directory doesn't exists" && exit 222
    fi
}

