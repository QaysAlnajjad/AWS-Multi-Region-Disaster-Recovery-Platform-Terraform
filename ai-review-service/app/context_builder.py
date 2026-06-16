import yaml


def load_file(path):

    with open(path, "r") as file:
        return file.read()



def build_context(
        terraform_plan,
        security_results,
        rules_file="rules/dr-policy.yaml"
):

    with open(rules_file, "r") as file:
        rules = yaml.safe_load(file)


    context = f"""

You are an AWS Cloud Architect reviewing
a Disaster Recovery Terraform deployment.


Project:

{rules['project']}


Terraform Changes:

{terraform_plan}



Security Scan Results:

{security_results}



Business Rules:

{rules}



Analyze the infrastructure change.

Return:

1. Risk level (LOW/MEDIUM/HIGH)
2. Problems found
3. Security impact
4. Cost impact
5. Recommended fixes

"""


    return context