#!/usr/bin/env bash

buckets_to_be_empty=$(aws s3 ls | awk '{ print $(NF) }' | egrep '^bucket-|^terraform-state')

for bucket in ${buckets_to_be_empty}; do 
    result_del_objs_in_bucket=$(aws s3api delete-objects \
    --bucket ${bucket} \
    --delete "$(aws s3api list-object-versions \
    --bucket "${bucket}" \
    --output=json \
    --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')")
    result=$(aws s3api delete-objects --bucket ${bucket} \
                --delete "$(aws s3api list-object-versions \
                    --bucket ${bucket} \
                    --query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')")
    echo $result
    # result_del_objs_in_bucket=$(aws s3 rm s3://${bucket} --recursive)
    echo ${result_del_objs_in_bucket}
    result_delete_bucket=$(aws s3 rb s3://${bucket} --force)
    echo ${result_delete_bucket}  
done