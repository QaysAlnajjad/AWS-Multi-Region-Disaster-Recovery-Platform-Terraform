output "knowledge_bucket" {
  value = module.knowledge_bucket.bucket_name
}

output "knowledge_base_id" {
  value = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_role" {
  value = module.bedrock_role.role_arn
}
