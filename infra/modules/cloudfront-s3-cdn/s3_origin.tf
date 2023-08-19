# 
# S3 bucket origin
#####################################

resource "aws_s3_bucket" "origin" {
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled" - enabled on CloudFront
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled" - not required in our case
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled" - not required in our case
  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"  - not required in our case
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default" - using sse algorithm instead
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.origin.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.origin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.origin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.s3_policy_document.json
}

data "aws_iam_policy_document" "s3_policy_document" {
  statement {
    sid       = "S3GetObjectForCloudFront"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]

    }
  }

}
