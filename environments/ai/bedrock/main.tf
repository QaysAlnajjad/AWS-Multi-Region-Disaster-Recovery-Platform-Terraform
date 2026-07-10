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
        "s3:GetObject",
        "s3:ListBucket",
        "aoss:APIAccessAll",
        "aoss:DashboardsAccessAll"
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
//  Create OpenSearch 
//==================================================================================

//============= Encryption policy ============================================= 

resource "aws_opensearchserverless_security_policy" "encryption" {

  name = "terraform-rag-encryption"

  type = "encryption"

  policy = jsonencode({

    Rules = [
      {
        Resource = [
          "collection/terraform-rag"
        ]

        ResourceType = "collection"   // Applied on the whole collection not just an index
      }
    ]

    AWSOwnedKey = true

  })

}


//============= Network policy ============================================= 

resource "aws_opensearchserverless_security_policy" "network" {

  name = "terraform-rag-network"

  type = "network"

  policy = jsonencode([

    {

      Rules = [

        {

          Resource = [

            "collection/terraform-rag"

          ]

          ResourceType = "collection"

        }

      ]

      AllowFromPublic = true

    }

  ])

}


//============= Access policy ============================================= 

resource "aws_opensearchserverless_access_policy" "bedrock" {

  name = "terraform-rag-access"

  type = "data"

  policy = jsonencode([
    {

      Rules = [

        {

          ResourceType = "collection"

          Resource = [

            "collection/terraform-rag"

          ]

          Permission = [

            "aoss:*"

          ]

        },

        {

          ResourceType = "index"

          Resource = [

            "index/terraform-rag/*"

          ]

          Permission = [

            "aoss:*"

          ]

        }

      ]

      Principal = [

        module.bedrock_role.role_arn

      ]

    }

  ])

}


//============= OpenSearch Collection ============================================= 

resource "aws_opensearchserverless_collection" "vector" {

  name = "terraform-rag"

  type = "VECTORSEARCH"

  depends_on = [
  
    aws_opensearchserverless_security_policy.encryption,
  
    aws_opensearchserverless_security_policy.network
  
  ]

}


//==================================================================================
//  Create Bedrock data source
//==================================================================================

resource "aws_bedrockagent_data_source" "knowledge" {

  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id

  name = "terraform-documents"

  data_source_configuration {

    type = "S3"

    s3_configuration {

      bucket_arn = module.knowledge_bucket.bucket_arn

    }

  }

}


//==================================================================================
//  Create KW
//==================================================================================

resource "aws_bedrockagent_knowledge_base" "main" {

  name = "terraform-rag"

  role_arn = data.terraform_remote_state.foundation.outputs.role_arn

  knowledge_base_configuration {

    type = "VECTOR"      // RAG works with embeddings 

    vector_knowledge_base_configuration {

      embedding_model_arn = var.embedding_model_arn

    }

  }

  storage_configuration {

    type = "OPENSEARCH_SERVERLESS"

    opensearch_serverless_configuration {

      collection_arn    = data.terraform_remote_state.foundation.outputs.collection_arn

      vector_index_name = "terraform-index"

      field_mapping {

        vector_field   = "vector"

        text_field     = "text"

        metadata_field = "metadata"

      }

    }

  }

}


//==================================================================================
//  Create SSM Parameter Store 
//==================================================================================

resource "aws_ssm_parameter" "knowledge_base_id" {

  name  = "/wordpress/ai/knowledge-base/id"

  type  = "String"

  value = aws_bedrockagent_knowledge_base.main.id

}

resource "aws_ssm_parameter" "data_source_id" {

  name  = "/wordpress/ai/data-source/id"

  type  = "String"

  value = aws_bedrockagent_data_source.knowledge.id

}

resource "aws_ssm_parameter" "knowledge_bucket" {

  name  = "/wordpress/ai/knowledge-bucket/name"

  type  = "String"

  value = value = data.terraform_remote_state.foundation.outputs.bucket_name

}





