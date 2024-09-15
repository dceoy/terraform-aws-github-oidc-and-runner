resource "aws_iam_openid_connect_provider" "github" {
  count           = var.enable_github_oidc ? 1 : 0
  url             = var.github_enterprise_slug != null ? "https://token.actions.githubusercontent.com/${var.github_enterprise_slug}" : "https://token.actions.githubusercontent.com"
  thumbprint_list = [local.tls_certificate_sha1_fingerprint]
  client_id_list = setunion(
    toset(["sts.amazonaws.com"]),
    toset([for r in setunion(values(var.github_repositories_requiring_oidc)...) : "https://github.com/${split("/", r)[0]}"])
  )
  tags = {
    Name       = "${var.system_name}-${var.env_type}-github-iam-oidc-provider"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "github" {
  for_each              = length(aws_iam_openid_connect_provider.github) > 0 ? var.github_iam_oidc_provider_iam_policy_arns : {}
  name                  = "${var.system_name}-${var.env_type}-github-iam-oidc-provider-${each.key}-iam-role"
  description           = "GitHub OIDC provider ${each.key} IAM role"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.github_enterprise_slug != null ? "${aws_iam_openid_connect_provider.github[0].arn}/${var.github_enterprise_slug}" : aws_iam_openid_connect_provider.github[0].arn
        }
        Action = ["sts:AssumeRoleWithWebIdentity"]
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              for r in var.github_repositories_requiring_oidc[each.key] : "repo:${r}:*"
            ]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
  managed_policy_arns = each.value
  tags = {
    Name       = "${var.system_name}-${var.env_type}-github-iam-oidc-provider-${each.key}-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
