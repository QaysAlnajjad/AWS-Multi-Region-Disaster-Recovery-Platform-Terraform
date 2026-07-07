import json
import sys

import boto3

from review_prompt import build_prompt


# ==============================================================================
# AWS Clients
# ==============================================================================

bedrock_agent = boto3.client(
    "bedrock-agent-runtime",
    region_name="us-east-1"
)

bedrock = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)


# ==============================================================================
# Inputs
# ==============================================================================

if len(sys.argv) != 3:
    raise SystemExit(
        "Usage: python bedrock_review.py <terraform-result.json> <knowledge-base-id>"
    )

input_file = sys.argv[1]
knowledge_base_id = sys.argv[2]


# ==============================================================================
# Load Terraform Scan Result
# ==============================================================================

with open(input_file, "r") as f:
    terraform_result = json.load(f)


# ==============================================================================
# Retrieve Context from Bedrock Knowledge Base
# ==============================================================================

retrieval_query = f"""
Review the following Terraform infrastructure.

Retrieve all documentation related to:

- services used
- AWS best practices
- security
- production readiness
- networking
- IAM
- disaster recovery

Terraform result:

{json.dumps(terraform_result)}
"""
retrieval = bedrock_agent.retrieve(
    knowledgeBaseId=knowledge_base_id,
    retrievalQuery={
        "text": retrieval_query
    },
    retrievalConfiguration={
        "vectorSearchConfiguration": {
            "numberOfResults": 10
        }
    }
)


# ==============================================================================
# Build Context
# ==============================================================================

context = ""

for item in retrieval.get("retrievalResults", []):
    text = item.get("content", {}).get("text", "")

    if text:
        context += text
        context += "\n\n------------------------------------------------------------\n\n"

if context == "":
    context = "No knowledge base documents were retrieved."


# ==============================================================================
# Build Prompt
# ==============================================================================

prompt = build_prompt(
    context=context,
    terraform_result=terraform_result
)


# ==============================================================================
# Invoke Claude
# ==============================================================================

response = bedrock.invoke_model(
    modelId="anthropic.claude-3-5-sonnet-20241022-v2:0",
    contentType="application/json",
    accept="application/json",
    body=json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 4096,
        "temperature": 0,
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


# ==============================================================================
# Parse Claude Response
# ==============================================================================

body = json.loads(response["body"].read())

answer = body["content"][0]["text"].strip()


# ==============================================================================
# Parse JSON Response
# ==============================================================================

try:
    result = json.loads(answer)

except json.JSONDecodeError:

    result = {
        "error": "Claude did not return valid JSON.",
        "raw_response": answer
    }


# ==============================================================================
# Save Report
# ==============================================================================

with open("ai-report.json", "w") as f:
    json.dump(result, f, indent=4)


print("AI review completed.")
print("Report saved to ai-report.json")
