#!/usr/bin/env bash

set -euo pipefail

################################################################################
# AI Configuration
################################################################################

AWS_REGION="${AWS_REGION:-us-east-1}"

################################################################################
# Read Parameters from SSM Parameter Store
################################################################################

export KNOWLEDGE_BASE_ID=$(
aws ssm get-parameter \
    --region "${AWS_REGION}" \
    --name "/ai/knowledge-base/id" \
    --query "Parameter.Value" \
    --output text
)

export DATA_SOURCE_ID=$(
aws ssm get-parameter \
    --region "${AWS_REGION}" \
    --name "/ai/data-source/id" \
    --query "Parameter.Value" \
    --output text
)

export KNOWLEDGE_BUCKET=$(
aws ssm get-parameter \
    --region "${AWS_REGION}" \
    --name "/ai/knowledge-bucket/name" \
    --query "Parameter.Value" \
    --output text
)

################################################################################
# Validation
################################################################################

if [[ -z "${KNOWLEDGE_BASE_ID}" ]]; then
    echo "ERROR: KNOWLEDGE_BASE_ID is empty."
    exit 1
fi

if [[ -z "${DATA_SOURCE_ID}" ]]; then
    echo "ERROR: DATA_SOURCE_ID is empty."
    exit 1
fi

if [[ -z "${KNOWLEDGE_BUCKET}" ]]; then
    echo "ERROR: KNOWLEDGE_BUCKET is empty."
    exit 1
fi

################################################################################
# Summary
################################################################################

echo "AI configuration loaded successfully."

echo "Knowledge Base : ${KNOWLEDGE_BASE_ID}"
echo "Data Source    : ${DATA_SOURCE_ID}"
echo "Knowledge Bucket: ${KNOWLEDGE_BUCKET}"
