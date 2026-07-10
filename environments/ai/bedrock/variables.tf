variable "knowledge_bucket_name" {

  description = "S3 bucket used to store Bedrock knowledge documents."

  type = string

  default = "wordpress-ai-knowledge"

}

variable "embedding_model_arn" {

  description = "Bedrock embedding model ARN."

  type = string

  default = "wordpress-ai-knowledge"

}
