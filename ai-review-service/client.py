import requests
import json


with open(
"terraform-plan.json"
) as f:

    plan=f.read()



with open(
"tfsec-results.json"
) as f:

    security=f.read()



response=requests.post(

"http://AI-SERVICE-ENDPOINT/review",

json={

"terraform_plan":plan,

"security_results":security

}

)



result=response.json()



print(result["review"])



if "HIGH" in result["review"]:

    exit(1)