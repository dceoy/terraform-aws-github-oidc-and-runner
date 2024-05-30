resource "aws_iam_openid_connect_provider" "github" {
  count           = length(var.github_repositories_requiring_oidc) > 0 ? 1 : 0
  url             = var.github_enterprise_slug != null ? "https://token.actions.githubusercontent.com/${var.github_enterprise_slug}" : "https://token.actions.githubusercontent.com"
  thumbprint_list = [local.tls_certificate_sha1_fingerprint]
  client_id_list = setunion(
    toset(["sts.amazonaws.com"]),
    toset([for r in var.github_repositories_requiring_oidc : "https://github.com/${split("/", r)[0]}"])
  )
  tags = {
    Name       = "${var.system_name}-${var.env_type}-github-iam-oidc-provider"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "github" {
  count       = length(aws_iam_openid_connect_provider.github) > 0 ? 1 : 0
  name        = "${var.system_name}-${var.env_type}-github-iam-oidc-provider-iam-role"
  description = "GitHub OIDC provider IAM role"
  path        = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.github_enterprise_slug != null ? "${aws_iam_openid_connect_provider.github[count.index].arn}/${var.github_enterprise_slug}" : aws_iam_openid_connect_provider.github[count.index].arn
        }
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for r in var.github_repositories_requiring_oidc : "repo:${r}:*"
            ]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  managed_policy_arns = var.github_iam_oidc_provider_iam_policy_arns
  tags = {
    Name       = "${var.system_name}-${var.env_type}-github-iam-oidc-provider-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
