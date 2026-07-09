output "knowledge_bucket" {
  value = module.knowledge_bucket.bucket_name
}

output "knowledge_base_id" {
  value = aws_bedrockagent_knowledge_base.main.id
}

output "knowledge_base_role" {
  value = module.bedrock_role.role_arn
}

output "data_source_id" {
 value = aws_bedrockagent_data_source.knowledge.id
}
