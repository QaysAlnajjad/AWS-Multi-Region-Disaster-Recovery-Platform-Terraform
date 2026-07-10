import boto3
import time
import sys


REGION = "us-east-1"


ssm = boto3.client(
    "ssm",
    region_name=REGION
)


bedrock = boto3.client(
    "bedrock-agent",
    region_name=REGION
)



def get_parameter(name):

    response = ssm.get_parameter(
        Name=name
    )

    return response["Parameter"]["Value"]



def put_parameter(name,value):

    ssm.put_parameter(

        Name=name,

        Value=value,

        Type="String",

        Overwrite=True

    )



role_arn = get_parameter(
    "/wordpress/ai/bedrock/role-arn"
)



bucket_name = get_parameter(
    "/wordpress/ai/knowledge/bucket-name"
)



bucket_arn = f"arn:aws:s3:::{bucket_name}"



print("Creating Knowledge Base...")



response = bedrock.create_knowledge_base(

    name="terraform-rag",

    description="Terraform infrastructure review knowledge base",

    roleArn=role_arn,


    knowledgeBaseConfiguration={

        "type":"VECTOR",

        "vectorKnowledgeBaseConfiguration":{

            "embeddingModelArn":

            "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"

        }

    },


    storageConfiguration={

        "type":"OPENSEARCH_SERVERLESS",

        "opensearchServerlessConfiguration":{

        }

    }

)
