import boto3
import json
import sys

from review_prompt import build_prompt


bedrock_agent = boto3.client(
    "bedrock-agent-runtime",
    region_name="us-east-1"
)



bedrock = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)



input_file=sys.argv[1]

kb_id=sys.argv[2]



with open(input_file) as f:

    terraform_result=json.load(f)



query = """
AWS Terraform best practices

Terraform infrastructure review

AWS Well Architected Framework

Security Best Practices

IAM Least Privilege

Networking

High Availability

Disaster Recovery

Production Readiness

Terraform Modules

Terraform Security

Cost Optimization

Logging

Monitoring

Encryption

Secrets Manager

VPC

ALB

ECS

RDS

S3
"""





retrieval = bedrock_agent.retrieve(

    knowledgeBaseId=kb_id,

    retrievalQuery={

        "text":query

    },

    retrievalConfiguration={

        "vectorSearchConfiguration":{

            "numberOfResults":5

        }

    }

)





context = ""

for item in retrieval["retrievalResults"]:

    context += item["content"]["text"]

    context += "\n\n--------------------------------\n\n"
    




prompt = build_prompt(
    context=context,
    terraform_result=terraform_result
)



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



body = json.loads(
    response["body"].read()
)

answer = body["content"][0]["text"]

result = json.loads(answer)



with open("ai-report.json","w") as f:

    json.dump(result,f,indent=2)

