#!/usr/bin/env bash

create_tg_alb(){
    if [[ $# != 4 ]]; then echo "Usage: ./$(basename $0) alb_name alb_port tg_name tg_port"; exit 74; fi
    alb_name=$1
    alb_port=$2
    tg_name=$3
    tg_port=$4

    AWS_ALB_ARN=$(aws elbv2 create-load-balancer \
        --name ${alb_name} \
        --subnets $subnet_pub_1 $subnet_pub_2 $subnet_pub_3 \
        --security-groups $alb_sg_id \
        --query 'LoadBalancers[0].LoadBalancerArn' \
        --region ${region_name} \
        --output text)

    while [ $(aws elbv2 describe-load-balancers --load-balancer-arns $AWS_ALB_ARN --query 'LoadBalancers[0].State.Code' --region ${region_name} --output text) == 'provisioning' ]; do
        echo "Loadbalancer ${alb_name} still creating"
        sleep 5
    done

    AWS_ALB_DNS=$(aws elbv2 describe-load-balancers \
        --load-balancer-arns $AWS_ALB_ARN \
        --query 'LoadBalancers[0].DNSName' \
        --region ${region_name} \
        --output text) && echo $AWS_ALB_DNS

    AWS_ALB_TARGET_GROUP_ARN=$(aws elbv2 create-target-group \
        --name ${tg_name} \
        --protocol HTTP --port ${tg_port} \
        --vpc-id $vpc_id \
        --target-type ip \
        --query 'TargetGroups[0].TargetGroupArn' \
        --region ${region_name} \
        --output text)


    AWS_ALB_LISTNER_ARN=$(aws elbv2 create-listener --load-balancer-arn $AWS_ALB_ARN \
        --protocol HTTP --port ${alb_port}  \
        --default-actions Type=forward,TargetGroupArn=$AWS_ALB_TARGET_GROUP_ARN \
        --query 'Listeners[0].ListenerArn' \
        --region ${region_name} \
        --output text)
}