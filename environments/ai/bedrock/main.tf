//==================================================================================
// IAM Role for Bedrock
//==================================================================================

module "bedrock_role" {

  source = "../../modules/iam"


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

        "s3:ListBucket"

      ]


      Resource = [

        "*"

      ]

    }

  ]

}


//==================================================================================
// Knowledge Documents Bucket
//==================================================================================

module "knowledge_bucket" {

  source = "../../modules/s3"


  s3_bucket_name = var.knowledge_bucket_name


  cloudfront_distribution_arn = ""

  ecs_task_role_arn = ""

  s3_vpc_endpoint_id = ""

}


//==================================================================================
// Store values for workflows
//==================================================================================


resource "aws_ssm_parameter" "bedrock_role" {


  name = "/wordpress/ai/bedrock/role-arn"


  type = "String"


  value = module.bedrock_role.role_arn

}



resource "aws_ssm_parameter" "knowledge_bucket" {


  name = "/wordpress/ai/knowledge/bucket-name"


  type = "String"


  value = module.knowledge_bucket.bucket_name

}
