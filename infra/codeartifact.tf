data "aws_kms_key" "codeartifact_key" {
  key_id = "alias/aws/codeartifact"
}

resource "aws_codeartifact_domain" "example" {
  domain         = "nbekenov"
  encryption_key = data.aws_kms_key.codeartifact_key.arn
}

resource "aws_codeartifact_repository" "example" {
  repository = "my-example-repo"
  domain     = aws_codeartifact_domain.example.domain
}
