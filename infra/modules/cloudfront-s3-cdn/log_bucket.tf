resource "aws_s3_bucket" "log_bucket" {
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled" - this is log bcket
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled" - this is log bcket
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled" - not required in our case
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled" - not required in our case
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"  - not required in our case
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default" - using sse algorithm instead
  bucket        = var.log_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "canonical_user" {}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.log_bucket]

  bucket = aws_s3_bucket.log_bucket.id

  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    grant {
      grantee {
        id   = data.aws_cloudfront_log_delivery_canonical_user_id.canonical_user.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket                  = aws_s3_bucket.log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads" - not required for cloudfront logs
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    id     = "DeleteAfterNDays"
    status = "Enabled"

    expiration {
      days = var.log_retention
    }
  }
}