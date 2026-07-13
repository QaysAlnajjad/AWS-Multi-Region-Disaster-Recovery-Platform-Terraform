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
Project architecture
Repository standards
Infrastructure conventions
Terraform module structure
Naming conventions
Review rules
Deployment architecture
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
# Converse API
################################################################################

response = bedrock.converse(

    modelId="nvidia.nemotron-nano-12b-v2",

    inferenceConfig={

        "maxTokens": 4096,

        "temperature": 0

    },

    messages=[

        {

            "role": "user",

            "content": [

                {

                    "text": prompt

                }

            ]

        }

    ]

)



################################################################################
# Parse Response
################################################################################

print(json.dumps(response, indent=2, default=str))

answer = response["output"]["message"]["content"][0]["text"]

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
