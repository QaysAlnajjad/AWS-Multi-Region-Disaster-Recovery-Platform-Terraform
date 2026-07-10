output "role_arn" { 
  value = module.bedrock_role.role_arn
}

output "bucket_arn" { 
  value = module.knowledge_bucket.bucket_arn
}

output "bucket_name" {
  value = module.knowledge_bucket.bucket_name
}

output "collection_arn" { 
  value = aws_opensearchserverless_collection.vector.arn
}

output "collection_endpoint" {
  value = aws_opensearchserverless_collection.vector.collection_endpoint
}
