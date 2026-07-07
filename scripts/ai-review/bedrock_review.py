import boto3
import json
import sys



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

Review this Terraform result.
Find security issues,
architecture problems,
and production risks.

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



context=""


for item in retrieval["retrievalResults"]:

    context += item["content"]["text"]



prompt=f"""

You are a senior AWS DevOps architect.


Knowledge:


{context}



Terraform Result:


{terraform_result}



Return JSON only:

{{
"severity":"",
"issues":[],
"recommendations":[]
}}

"""



response = bedrock.invoke_model(

    modelId="anthropic.claude-3-5-sonnet-20240620-v1:0",

    body=json.dumps({

        "messages":[

            {

             "role":"user",

             "content":prompt

            }

        ],

        "max_tokens":2000,

        "anthropic_version":"bedrock-2023-05-31"

    })

)



result=json.loads(
    response["body"].read()
)



with open("ai-report.json","w") as f:

    json.dump(result,f,indent=2)

