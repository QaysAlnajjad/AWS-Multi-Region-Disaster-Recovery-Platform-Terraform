variable "knowledge_bucket_name" {


  type = string


  default = "wordpress-ai-knowledge"


}



variable "embedding_model_arn" {


  type = string


  default = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"


}
