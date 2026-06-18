#!/bin/bash

set -e


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/stacks_config.sh"


echo "DEBUG:"
echo "TF_STATE_BUCKET_NAME=$TF_STATE_BUCKET_NAME"
echo "TF_STATE_BUCKET_REGION=$TF_STATE_BUCKET_REGION"



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


echo "Running terraform plan for validation only"


terraform -chdir="environments/$stack" plan \
${STACK_VARS[$stack]} \
-no-color

}



verify_stack "global/iam"
