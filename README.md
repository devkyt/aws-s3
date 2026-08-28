# AWS S3

OpenTofu module for S3 bucket provisioning. You can find how to use it in [example](./example/) folder
and in the [Examples](#examples) section below.

## Table of Contents

- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)
  - [Basic Bucket](#basic-bucket)
  - [Bucket with IAM Policy](#bucket-with-iam-policy)
  - [Restricting Access to Specific Paths](#restricting-access-to-specific-paths)
  - [CORS Configuration](#cors-configuration)
  - [KMS Encryption](#kms-encryption)

## Requirements

| Name | Version |
|------|---------|
| OpenTofu | >= 1.11 |
| AWS provider | ~> 6.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name of the S3 bucket | `string` | - | yes |
| `env` | Target environment | `string` | - | yes |
| `allow_force_destroy` | Allow destruction of the bucket with all existing objects inside | `bool` | `false` | no |
| `enable_versioning` | Support versioning for the objects inside the bucket | `bool` | `false` | no |
| `kms_key_arn` | KMS key for bucket encryption. If not passed default AES256 will be used | `string` | `null` | no |
| `iam_policy` | IAM policy statements for the bucket policy. Resource is automatically set to the bucket ARN and bucket ARN/* unless paths are specified | `list(object)` | `[]` | no |
| `enforce_ssl` | Deny all HTTP requests to the bucket by attaching a policy with aws:SecureTransport condition | `bool` | `true` | no |
| `cors` | CORS rules for the S3 bucket | `list(object)` | `[]` | no |
| `use_name_prefix` | Use name_prefix instead of a fixed name for created resources, so AWS appends a unique suffix | `bool` | `false` | no |
| `include_default_tags` | Whether or not to attach default tags specified in module | `bool` | `true` | no |
| `tags` | Tags to attach to S3 bucket and the related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `arn` | ARN of the created S3 bucket |
| `name` | Name of the created S3 bucket |
| `domain` | Domain name of the created S3 bucket |
| `regional_domain` | Region-specific domain name of the created S3 bucket |
| `hosted_zone_id` | Route53 hosted zone ID for the created S3 bucket |

## Examples

### Basic Bucket

A minimal S3 bucket with SSL enforcement enabled by default.

```hcl
module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = "experiment"

  enable_versioning = true
}
```

### Bucket with IAM Policy

Granting cross-account read access to the entire bucket.

```hcl
module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = "experiment"

  iam_policy = [
    {
      sid = "AllowCrossAccountRead"
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:root"]
      }
      actions = ["s3:GetObject", "s3:ListBucket"]
    }
  ]
}
```

### Restricting Access to Specific Paths

When `paths` is provided, the policy resources are scoped to those prefixes
instead of the entire bucket.

```hcl
module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = "experiment"

  iam_policy = [
    {
      sid = "AllowReadReports"
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:role/reporting"]
      }
      actions = ["s3:GetObject"]
      paths   = ["reports/*", "exports/*"]
    }
  ]
}
```

### CORS Configuration

Allowing cross-origin requests from a specific domain.

```hcl
module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = "experiment"

  cors = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
    }
  ]
}
```

### KMS Encryption

Using a custom KMS key instead of the default AES256 encryption.

```hcl
module "s3" {
  source = "git@github.com:devkyt/aws-s3.git?ref=main&depth=1"

  name = "rd-experiments"
  env  = "experiment"

  kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## License

Licensed under the Apache License, Version 2.0.

Copyright 2026 Kyrylo Tykhanskyi.
