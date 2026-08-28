output "arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.main.arn
}


output "name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.main.id
}


output "domain" {
  description = "Domain name of the created S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}


output "regional_domain" {
  description = "Region-specific domain name of the created S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}


output "hosted_zone_id" {
  description = "Route53 hosted zone ID for the created S3 bucket"
  value       = aws_s3_bucket.main.hosted_zone_id
}
