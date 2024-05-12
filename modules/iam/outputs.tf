output "github_iam_oidc_provider_arn" {
  description = "GitHub IAM OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "github_iam_oidc_provider_iam_role_arn" {
  description = "GitHub IAM OIDC provider IAM role ARN"
  value       = aws_iam_role.github.arn
}
