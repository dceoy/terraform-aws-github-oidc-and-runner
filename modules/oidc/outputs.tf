output "github_iam_oidc_provider_arn" {
  description = "GitHub IAM OIDC provider ARN"
  value       = length(aws_iam_openid_connect_provider.github) > 0 ? aws_iam_openid_connect_provider.github[0].arn : null
}

output "github_iam_oidc_provider_iam_role_arns" {
  description = "GitHub IAM OIDC provider IAM role ARNs"
  value       = length(aws_iam_role.github) > 0 ? values(aws_iam_role.github)[*].arn : []
}
