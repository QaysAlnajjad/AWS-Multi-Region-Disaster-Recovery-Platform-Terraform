//

module "bedrock_role" {
  source = "../../../modules/iam"

  role_name = "bedrock-kb-role"

  policy_name = "bedrock-kb-policy"

  assume_role_services = [
    "bedrock.amazonaws.com"
  ]

  managed_policy_arns = []

  inline_policy_statements = [
    {
      Effect = "Allow"

      Action = [
        "bedrock:*",
        "s3:GetObject",
        "s3:ListBucket",
        "aoss:*"
      ]

      Resource = [
        "*"
      ]
    }
  ]
}
