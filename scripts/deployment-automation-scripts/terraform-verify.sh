#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/stacks_config.sh"


verify_stack(){

stack=$1

echo "======================"
echo "Checking $stack"
echo "======================"


terraform -chdir="environments/$stack" init \
-reconfigure \
-backend=false


terraform -chdir="environments/$stack" validate



terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
-no-color \
-out=tfplan



terraform -chdir="environments/$stack" show \
-json tfplan \
> "$GITHUB_WORKSPACE/ai-results/${stack//\//_}-plan.json"


}


# نفس ترتيب الـ deploy

verify_stack "global/iam"

verify_stack "global/oac"

verify_stack "primary/network"

verify_stack "primary/rds"


echo "Running dynamic values..."



ECS_TASK_ROLE_ARN=$(terraform \
-chdir="environments/global/iam" \
output -raw ecs_task_role_arn || true)



CLOUDFRONT_DISTRIBUTION_ARN=$(terraform \
-chdir="environments/global/cdn_dns" \
output -raw cloudfront_distribution_arn || true)



STACK_VARS["primary/s3"]+=" \
-var cloudfront_distribution_arn=$CLOUDFRONT_DISTRIBUTION_ARN \
-var ecs_task_role_arn=$ECS_TASK_ROLE_ARN"



STACK_VARS["dr/s3"]+=" \
-var cloudfront_distribution_arn=$CLOUDFRONT_DISTRIBUTION_ARN \
-var ecs_task_role_arn=$ECS_TASK_ROLE_ARN"



STACK_VARS["primary/ecs"]+=" \
-var ecs_cluster_name=$ECS_CLUSTER_NAME \
-var ecs_service_name=$ECS_SERVICE_NAME"



STACK_VARS["dr/ecs"]+=" \
-var ecs_cluster_name=$ECS_CLUSTER_NAME \
-var ecs_service_name=$ECS_SERVICE_NAME"



verify_stack "primary/s3"

verify_stack "dr/s3"

verify_stack "primary/alb"

verify_stack "dr/alb"

verify_stack "primary/ecs"

verify_stack "dr/ecs"

verify_stack "operations/dr_orchestration"



STACK_VARS["primary/failover_alarms"]+=" \
-var sns_email=$SNS_EMAIL \
-var ecs_cluster_name=$ECS_CLUSTER_NAME \
-var ecs_service_name=$ECS_SERVICE_NAME"



verify_stack "primary/failover_alarms"



echo "Verification completed"
