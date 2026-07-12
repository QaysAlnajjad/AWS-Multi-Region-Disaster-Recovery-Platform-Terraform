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

response = requests.delete(
    url,
    auth=auth,
    headers={
        "Content-Type": "application/json"
    }
)

# إذا لم يكن الـ index موجوداً فلا نعتبرها مشكلة
if response.status_code == 404:
    print("Index does not exist.")
    sys.exit(0)

print(response.text)

response.raise_for_status()

print("Index deleted successfully.")
