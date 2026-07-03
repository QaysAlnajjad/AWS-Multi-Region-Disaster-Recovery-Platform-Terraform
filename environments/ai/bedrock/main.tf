//==================================================================================
//  Create IAM role
//==================================================================================

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
        "aoss:*"     // allow read/write from Vector Store
      ]

      Resource = [
        "*"
      ]
    }
  ]
}


//==================================================================================
//  Create S3 bucket
//==================================================================================

module "knowledge_bucket" {

  source = "../../../modules/s3"

  s3_bucket_name = var.knowledge_bucket_name

  cloudfront_distribution_arn = ""

  ecs_task_role_arn = ""

  s3_vpc_endpoint_id = ""
}


//==================================================================================
//  Create KW
//==================================================================================

resource "aws_bedrockagent_knowledge_base" "main" {

  name = "terraform-rag"

  role_arn = module.bedrock_role.role_arn

  knowledge_base_configuration {

    type = "VECTOR"

    vector_knowledge_base_configuration {

      embedding_model_arn = var.embedding_model_arn

    }

  }

  storage_configuration {

    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {

      collection_arn    = aws_opensearchserverless_collection.vector.arn

      vector_index_name = "terraform-index"

      field_mapping {

        vector_field   = "vector"

        text_field     = "text"

        metadata_field = "metadata"

      }

    }

  }

}
