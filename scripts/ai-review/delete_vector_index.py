import sys
import boto3
import requests

from requests_aws4auth import AWS4Auth

###############################################################################
# Configuration
###############################################################################

endpoint = sys.argv[1]

region = "us-east-1"

index_name = "terraform-index"

###############################################################################
# AWS Authentication
###############################################################################

session = boto3.Session()

credentials = session.get_credentials()

auth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    "aoss",
    session_token=credentials.token,
)

###############################################################################
# Delete Index
###############################################################################

url = f"{endpoint}/{index_name}"

response = requests.delete(
    url,
    auth=auth,
    headers={
        "Content-Type": "application/json"
    }
)

###############################################################################
# Output
###############################################################################

print(response.text)

# Ignore "index not found"
if response.status_code == 404:
    print("Index does not exist.")
    sys.exit(0)

response.raise_for_status()

print("Vector index deleted successfully.")
