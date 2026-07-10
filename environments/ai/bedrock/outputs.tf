output "knowledge_base_id" {

 value = aws_bedrockagent_knowledge_base.main.id

}


output "data_source_id" {

 value = aws_bedrockagent_data_source.knowledge.id

}


output "knowledge_bucket_name" {

 value = module.knowledge_bucket.bucket_name

}
