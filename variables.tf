variable "name" {
  description = "Name of the S3 bucket"
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 63
    error_message = "Bucket name must be between 3 and 63 characters long."
  }

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.name))
    error_message = "Bucket name must start and end with a lowercase letter or number, and contain only lowercase letters, numbers, dots, and hyphens."
  }

  validation {
    condition     = !can(regex("[.]{2,}", var.name))
    error_message = "Bucket name must not contain consecutive dots."
  }

  validation {
    condition     = !can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$", var.name))
    error_message = "Bucket name must not be formatted as an IP address."
  }
}


variable "env" {
  description = "Target environment"
  type        = string

  validation {
    condition     = length(var.env) > 0
    error_message = "Environment cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.env))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}


variable "allow_force_destroy" {
  description = "Allow destruction of the bucket with all existing objects inside"
  type        = bool
  default     = false
}


variable "enable_versioning" {
  description = "Support versioning for the objects inside the bucket"
  type        = bool
  default     = false
}


variable "kms_key_arn" {
  description = "KMS key for bucket encryption. If not passed default AES256 will be used"
  type        = string
  default     = null

  validation {
    condition = (
      var.kms_key_arn == null ||
      can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.kms_key_arn))
    )
    error_message = "KMS key ARN must be in a valid format: arn:aws:kms:region:account-id:key/key-id."
  }
}


variable "iam_policy" {
  description = "IAM policy statements for the bucket policy. Resource is automatically set to the bucket ARN (and bucket ARN/* for objects). Pass paths to restrict to specific object key prefixes."
  type = list(object({
    sid    = optional(string)
    effect = optional(string, "Allow")
    principals = object({
      type        = string
      identifiers = list(string)
    })
    actions = list(string)
    paths   = optional(list(string))
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}


variable "enforce_ssl" {
  description = "Deny all HTTP requests to the bucket by attaching a policy with aws:SecureTransport condition"
  type        = bool
  default     = true
}


variable "cors" {
  description = "CORS rules for the S3 bucket"
  type = list(object({
    allowed_headers = optional(list(string), ["*"])
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = optional(list(string), [])
    max_age_seconds = optional(number, 3600)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.cors : alltrue([
        for method in rule.allowed_methods :
        contains(["GET", "PUT", "POST", "DELETE", "HEAD"], method)
      ])
    ])
    error_message = "Allowed methods must be one of: GET, PUT, POST, DELETE, HEAD."
  }

  validation {
    condition = alltrue([
      for rule in var.cors : length(rule.allowed_origins) > 0
    ])
    error_message = "Each CORS rule must have at least one allowed origin."
  }

  validation {
    condition = alltrue([
      for rule in var.cors : rule.max_age_seconds >= 0 && rule.max_age_seconds <= 86400
    ])
    error_message = "Max age must be between 0 and 86400 seconds (24 hours)."
  }
}


variable "use_name_prefix" {
  description = "Use name_prefix instead of a fixed name for the resources this module creates, so AWS appends a unique suffix"
  type        = bool
  default     = false
}


variable "include_default_tags" {
  description = "Whether or not to attach default tags specified in module"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to attach to S3 bucket and the related resources"
  type        = map(string)
  default     = {}
}
