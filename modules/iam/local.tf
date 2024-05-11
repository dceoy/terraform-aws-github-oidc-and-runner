data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

locals {
  tls_certificate_sha1_fingerprint = data.tls_certificate.github.certificates[0].sha1_fingerprint
}
