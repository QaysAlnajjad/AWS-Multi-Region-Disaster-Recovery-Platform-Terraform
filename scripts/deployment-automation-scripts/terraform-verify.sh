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
-backend-config="bucket=$TF_STATE_BUCKET_NAME" \
-backend-config="key=environments/$stack/terraform.tfstate" \
-backend-config="region=$TF_STATE_BUCKET_REGION"



terraform -chdir="environments/$stack" fmt -check


terraform -chdir="environments/$stack" validate



TFVARS=""

if [ -f "environments/$stack/${stack##*/}.tfvars" ]
then
  TFVARS="-var-file=${stack##*/}.tfvars"
fi


set +e

terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
$TFVARS \
-no-color

RESULT=$?

set -e


if [ $RESULT -ne 0 ]; then

echo "❌ Terraform plan failed for $stack"

exit $RESULT

fi

echo "✅ $stack OK"

}



verify_stack "global/iam"
verify_stack "global/oac"

verify_stack "primary/network"
verify_stack "primary/rds"

verify_stack "dr/network"

verify_stack "primary/alb"

verify_stack "primary/ecs"

verify_stack "dr/ecs"

verify_stack "operations/dr_orchestration"

verify_stack "primary/failover_alarms"


echo "======================"
echo "Verification completed"
echo "======================"
