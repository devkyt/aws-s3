locals {
  env    = "experiment"
  region = "eu-central-1"

  tags = {
    Team   = "Research and Development"
    Office = "Hamburg"
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-experiments-state"
    region = "eu-central-1"
    key    = "s3/terraform.tfstate"
  }
}


provider "aws" {
  region = local.region
}


module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = local.env

  enable_versioning = true

  # SSL enforcement is enabled by default
  # enforce_ssl = true

  # Optional: structured bucket policy
  # iam_policy = [
  #   {
  #     sid = "AllowReadFromAccount"
  #     principals = {
  #       type        = "AWS"
  #       identifiers = ["arn:aws:iam::123456789012:root"]
  #     }
  #     actions = ["s3:GetObject"]
  #     paths   = ["data/*", "reports/*"]  # Restricts to specific prefixes
  #   }
  # ]

  # Optional: CORS rules
  # cors = [
  #   {
  #     allowed_methods = ["GET", "HEAD"]
  #     allowed_origins = ["https://example.com"]
  #   }
  # ]

  # Optional: KMS encryption (defaults to AES256)
  # kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/a1b2c3d4-e5f6-7890-abcd-ef1234567890"

  tags = local.tags
}
