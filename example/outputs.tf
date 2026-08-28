
output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3.arn
}


output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.s3.name
}


output "bucket_domain" {
  description = "Domain name of the created S3 bucket"
  value       = module.s3.domain
}
