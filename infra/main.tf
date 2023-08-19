
data "aws_cloudfront_response_headers_policy" "headers_policy" {
  name = "Managed-SecurityHeadersPolicy"
}

module "cloudfront_s3" {
  source = "./modules/cloudfront-s3-cdn/"

  bucket_name     = var.bucket_name
  log_bucket_name = "${var.bucket_name}-cloudfront-logs"
  ssl_cert_arn    = aws_acm_certificate.certificate_request.arn
  aliases         = [local.subdomain]

  response_headers_policy_id = data.aws_cloudfront_response_headers_policy.headers_policy.id
  # web_acl_id                 = data.aws_wafv2_web_acl.waf.arn

  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["US"]
  }

  depends_on = [
    aws_acm_certificate_validation.cert
  ]
}