
locals {
  bucket_name = "example"
  dns_name    = "complete"
  dns_parent  = "example.com"
  env_name    = "dev"
}

data "aws_cloudfront_response_headers_policy" "headers_policy" {
  name = "Managed-SecurityHeadersPolicy"
}

data "aws_route53_zone" "env" {
  name = "${local.env_name}.${local.dns_parent}"
}

data "aws_acm_certificate" "example" {
  domain      = "complete.example.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_wafv2_web_acl" "waf" {
  name  = local.web_acl_name
  scope = "CLOUDFRONT"
  provider = aws.east1
}

module "cloudfront_s3" {
  source = "../../"

  bucket_name     = local.bucket_name
  log_bucket_name = "${local.bucket_name}-cloudfront-logs"
  ssl_cert_arn    = data.aws_acm_certificate.example.arn
  aliases         = ["${local.dns_name}.${data.aws_route53_zone.env.name}"]

  response_headers_policy_id = data.aws_cloudfront_response_headers_policy.headers_policy.id
  web_acl_id                 = data.aws_wafv2_web_acl.waf.arn
  
  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["US", "IN", "GB"]
  }

  depends_on = [
    aws_acm_certificate_validation.cert
  ]
}