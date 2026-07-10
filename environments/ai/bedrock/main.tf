data "terraform_remote_state" "foundation" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name
    key    = "environments/ai/foundation/terraform.tfstate"
    region = var.state_bucket_region
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
//  Create Bedrock data source
//==================================================================================

resource "aws_bedrockagent_data_source" "knowledge" {

  knowledge_base_id = aws_bedrockagent_knowledge_base.main.id

  name = "terraform-documents"

  data_source_configuration {

    type = "S3"

    s3_configuration {

      bucket_arn = data.terraform_remote_state.foundation.outputs.bucket_arn

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

  value = module.knowledge_bucket.bucket_name

}





