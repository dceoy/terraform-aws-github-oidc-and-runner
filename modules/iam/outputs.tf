output "github_oidc_iam_role_arn" {
  description = "GitHub OIDC IAM role ARN"
  value       = aws_iam_role.github.arn
}

output "github_oidc_provider_arn" {
  description = "GitHub OIDC provider ARN"
  value       = aws_iam_openid_connect_provider.github.arn
}
