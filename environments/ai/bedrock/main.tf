//==================================================================================
// IAM Role for Bedrock
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

        "aoss:*"

      ]


      Resource = [

        "*"

      ]

    }

  ]

}


//==================================================================================
// S3 Knowledge Bucket
//==================================================================================

module "knowledge_bucket" {


  source = "../../../modules/s3"


  s3_bucket_name = var.knowledge_bucket_name


  cloudfront_distribution_arn = ""

  ecs_task_role_arn = ""

  s3_vpc_endpoint_id = ""

}


//==================================================================================
// OpenSearch Encryption Policy
//==================================================================================

resource "aws_opensearchserverless_security_policy" "encryption" {


  name = "terraform-rag-encryption"


  type = "encryption"



  policy = jsonencode({

    Rules = [

      {

        Resource = [

          "collection/terraform-rag"

        ]


        ResourceType = "collection"

      }

    ]


    AWSOwnedKey = true

  })

}



//==================================================================================
// OpenSearch Network Policy
//==================================================================================

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


//==================================================================================
// OpenSearch Access Policy
//==================================================================================

resource "aws_opensearchserverless_access_policy" "access" {


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

        module.bedrock_role.role_arn,
        "arn:aws:iam::127214183643:role/github-actions-terraform-role"

      ]

    }

  ])

}



//==================================================================================
// OpenSearch Collection
//==================================================================================

resource "aws_opensearchserverless_collection" "vector" {

  name = "terraform-rag"

  type = "VECTORSEARCH"

  depends_on = [

    aws_opensearchserverless_security_policy.encryption,

    aws_opensearchserverless_security_policy.network

  ]

}

resource "time_sleep" "wait_for_aoss" {

  depends_on = [
    aws_opensearchserverless_collection.vector,
    aws_opensearchserverless_access_policy.access
  ]

  create_duration = "60s"
}

resource "null_resource" "vector_index" {

  triggers = {
    endpoint = aws_opensearchserverless_collection.vector.collection_endpoint
  }

  provisioner "local-exec" {

    command = <<EOF

python ../../../scripts/ai-review/create_vector_index.py \
${self.triggers.endpoint}
EOF
  }

  provisioner "local-exec" {

    when = destroy

    command = <<EOF
python ../../../scripts/ai-review/delete_vector_index.py \
${self.triggers.endpoint}
EOF
  }
}


//==================================================================================
// Bedrock Knowledge Base
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


      collection_arn = aws_opensearchserverless_collection.vector.arn



      vector_index_name = "terraform-index"



      field_mapping {


        vector_field = "vector"


        text_field = "text"


        metadata_field = "metadata"


      }


    }


  }



  depends_on = [

    null_resource.vector_index

  ]

}


//==================================================================================
// Bedrock Data Source
//==================================================================================

resource "aws_bedrockagent_data_source" "main" {

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
// SSM Parameters
//==================================================================================

resource "aws_ssm_parameter" "knowledge_base_id" {

  name  = "/wordpress/ai/knowledge-base/id"

  type  = "String"

  value = aws_bedrockagent_knowledge_base.main.id
}

resource "aws_ssm_parameter" "data_source_id" {

  name  = "/wordpress/ai/data-source/id"

  type  = "String"

  value = aws_bedrockagent_data_source.main.data_source_id
}

resource "aws_ssm_parameter" "knowledge_bucket" {

  name  = "/wordpress/ai/knowledge-bucket/name"

  type  = "String"

  value = module.knowledge_bucket.bucket_name
}
