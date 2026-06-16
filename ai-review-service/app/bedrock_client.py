import boto3
import json


client = boto3.client(
    "bedrock-runtime",
    region_name="us-east-1"
)



MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0"



def ask_ai(prompt):


    body = {

        "anthropic_version":
        "bedrock-2023-05-31",

        "max_tokens": 2000,

        "messages":[
            {
                "role":"user",
                "content":prompt
            }
        ]

    }


    response = client.invoke_model(

        modelId=MODEL_ID,

        body=json.dumps(body)

    )


    result = json.loads(
        response["body"].read()
    )


    return result["content"][0]["text"]