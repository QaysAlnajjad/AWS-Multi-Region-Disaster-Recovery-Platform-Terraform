#!/usr/bin/env python3

import boto3
import json
import sys

from review_prompt import build_prompt


AWS_REGION = "us-east-1"


################################################################################
# Clients
################################################################################

bedrock_agent = boto3.client(
    "bedrock-agent-runtime",
    region_name=AWS_REGION
)


bedrock = boto3.client(
    "bedrock-runtime",
    region_name=AWS_REGION
)


################################################################################
# Arguments
################################################################################

input_file = sys.argv[1]

knowledge_base_id = sys.argv[2]


################################################################################
# Load Scan Results
################################################################################

with open(input_file, "r", encoding="utf-8") as f:

    terraform_result = json.load(f)


################################################################################
# Retrieve Knowledge Context
################################################################################

query = """
AWS Terraform best practices

AWS Well Architected Framework

Terraform security

IAM least privilege

Networking security

High availability

Disaster recovery

Encryption

Secrets management

Logging and monitoring

Cost optimization
"""


retrieval = bedrock_agent.retrieve(

    knowledgeBaseId=knowledge_base_id,

    retrievalQuery={

        "text": query

    },

    retrievalConfiguration={

        "vectorSearchConfiguration": {

            "numberOfResults": 5

        }

    }

)


context = ""


for item in retrieval["retrievalResults"]:

    context += item["content"]["text"]

    context += "\n\n--------------------\n\n"


################################################################################
# Build Prompt
################################################################################

prompt = build_prompt(

    context=context,

    terraform_result=json.dumps(
        terraform_result,
        indent=2
    )

)


################################################################################
# Invoke Claude
################################################################################

response = bedrock.invoke_model(

    modelId="anthropic.claude-3-5-sonnet-20241022-v2:0",

    contentType="application/json",

    accept="application/json",

    body=json.dumps({

        "anthropic_version": "bedrock-2023-05-31",

        "max_tokens": 4096,

        "messages": [

            {

                "role": "user",

                "content": [

                    {

                        "type": "text",

                        "text": prompt

                    }

                ]

            }

        ]

    })

)


################################################################################
# Parse Response
################################################################################

response_body = json.loads(

    response["body"].read()

)


answer = response_body["content"][0]["text"]


try:

    result = json.loads(answer)


except Exception:

    result = {

        "raw_response": answer

    }


################################################################################
# Save AI Result
################################################################################

with open(
    "ai-results/ai-analysis.json",
    "w",
    encoding="utf-8"
) as f:

    json.dump(

        result,

        f,

        indent=4

    )


print(
    "AI analysis completed successfully"
)
