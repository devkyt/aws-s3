# ---------------------------------------------
# S3 Bucket
# ---------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket        = var.name
  force_destroy = var.allow_force_destroy

  tags = merge(local.tags,
    {
      Name = var.name
      Type = "S3"
    },
  )
}


# ---------------------------------------------
# Bucket Versioning Configuration
# ---------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}


# ---------------------------------------------
# Object Ownership Controls
# ---------------------------------------------
resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# ---------------------------------------------
# Public Access Block
# ---------------------------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket_ownership_controls.main]
}


# ---------------------------------------------
# Server-Side Encryption Configuration
# ---------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }

    bucket_key_enabled = var.kms_key_arn != null
  }
}


# ---------------------------------------------
# Cross-Origin Resource Sharing Rules
# ---------------------------------------------
resource "aws_s3_bucket_cors_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors

    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }

  lifecycle {
    enabled = length(var.cors) > 0
  }
}


# ---------------------------------------------
# Bucket Policy Document (Access + SSL Enforcement)
# ---------------------------------------------
data "aws_iam_policy_document" "main" {
  dynamic "statement" {
    for_each = var.iam_policy

    content {
      sid     = statement.value.sid
      effect  = statement.value.effect
      actions = statement.value.actions

      resources = concat(
        [aws_s3_bucket.main.arn],
        statement.value.paths != null ?
        [
          for path in statement.value.paths : "${aws_s3_bucket.main.arn}/${path}"
        ] :
        [
          "${aws_s3_bucket.main.arn}/*",
        ]
      )

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  dynamic "statement" {
    for_each = var.enforce_ssl ? ["enable"] : []

    content {
      sid    = "DenyInsecureTransport"
      effect = "Deny"

      actions = ["s3:*"]

      resources = [
        aws_s3_bucket.main.arn,
        "${aws_s3_bucket.main.arn}/*",
      ]

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      condition {
        test     = "Bool"
        variable = "aws:SecureTransport"
        values   = ["false"]
      }
    }
  }

  lifecycle {
    enabled = local.create_bucket_policy
  }
}


# ---------------------------------------------
# Attach The Generated Bucket Policy
# ---------------------------------------------
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json

  lifecycle {
    enabled = local.create_bucket_policy
  }
}
