# 
# CloudFront configuration
#####################################

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "origin_access_identity"
}

resource "aws_cloudfront_distribution" "this" {

  depends_on = [
    aws_s3_bucket.log_bucket,
    aws_s3_bucket_ownership_controls.log_bucket,
    aws_s3_bucket_acl.log_bucket_acl
  ]

  origin {
    domain_name = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.origin.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN ${var.bucket_name}"
  default_root_object = "index.html"

  aliases = var.aliases

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log_bucket.bucket_domain_name
    prefix          = "cloudfront"
  }

  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = aws_s3_bucket.origin.bucket_regional_domain_name
    response_headers_policy_id = var.response_headers_policy_id

    # we don't need forward query strings or cookies to the origin
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = var.error_ttl
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = var.error_ttl
    response_code         = 200
    response_page_path    = "/index.html"
  }

  # add if needed ordered_cache_behavior {}

  restrictions {
    dynamic "geo_restriction" {
      for_each = [var.geo_restriction]

      content {
        restriction_type = lookup(geo_restriction.value, "restriction_type", "none")
        locations        = lookup(geo_restriction.value, "locations", [])
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.ssl_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  # The WAF Web ACL must exist in the WAF Global (CloudFront) region
  web_acl_id = var.web_acl_id

}