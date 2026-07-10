import sys
import boto3
import requests

from requests_aws4auth import AWS4Auth



endpoint = sys.argv[1]


region = "us-east-1"



session = boto3.Session()


credentials = session.get_credentials()



auth = AWS4Auth(

    credentials.access_key,

    credentials.secret_key,

    region,

    "aoss",

    session_token=credentials.token

)



index_name = "terraform-index"



url = f"{endpoint}/{index_name}"


body = {

    "settings": {

        "index": {

            "knn": True,

            "knn.algo_param.ef_search": 512

        }

    },

    "mappings": {

        "properties": {

            "vector": {

                "type": "knn_vector",

                "dimension": 1024,

                "method": {

                    "name": "hnsw",

                    "engine": "faiss",

                    "space_type": "l2"

                }

            },

            "text": {

                "type": "text"

            },

            "metadata": {

                "type": "text"

            }

        }

    }

}


response = requests.put(

    url,

    auth=auth,

    json=body,

    headers={

        "Content-Type":"application/json"

    }

)



print(response.text)



response.raise_for_status()
