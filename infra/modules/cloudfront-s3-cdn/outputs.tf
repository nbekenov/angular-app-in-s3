output "s3_bucket_name" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.origin.id
}

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_distribution_hosted_zone_id" {
  description = "The domain name corresponding to the distribution."
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}