variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default = "wordpress-ai-bedrock-135498"
}

variable "state_bucket_region" {
  description = "S3 bucket region for Terraform state"
  type        = string
  default = "eu-central-1"
}
