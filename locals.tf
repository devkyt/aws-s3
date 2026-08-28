locals {
  create_bucket_policy = length(var.iam_policy) > 0 || var.enforce_ssl

  default_tags = var.include_default_tags ? {
    Environment = var.env
    Env         = var.env
    Terraform   = "true"
    ManagedBy   = "Terraform"
  } : {}

  tags = merge(local.default_tags, var.tags)
}
