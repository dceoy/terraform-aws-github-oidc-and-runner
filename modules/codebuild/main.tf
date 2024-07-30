resource "aws_codebuild_project" "github" {
  for_each     = local.codebuild_project_names
  name         = each.value
  description  = "CodeBuild project for GitHub Actions"
  service_role = aws_iam_role.github.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  source {
    type                = var.github_enterprise_slug != null ? "GITHUB_ENTERPRISE" : "GITHUB"
    location            = "https://github.com/${each.key}.git"
    git_clone_depth     = 1
    insecure_ssl        = false
    report_build_status = false
    git_submodules_config {
      fetch_submodules = true
    }
    buildspec = <<-EOT
    ---
    version: 0.2
    phases:
      build:
        commands:
          - echo 'This buildspec will be overridden by GitHub Actions.'
    EOT
  }
  environment {
    type                        = var.codebuild_environment_type
    compute_type                = var.codebuild_environment_compute_type
    image                       = var.codebuild_environment_image
    image_pull_credentials_type = var.codebuild_environment_image_pull_credentials_type
    privileged_mode             = var.codebuild_environment_privileged_mode
  }
  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.github.name
      stream_name = each.key
      status      = "ENABLED"
    }
  }
  build_timeout  = var.codebuild_build_timeout
  queued_timeout = var.codebuild_queued_timeout
  tags = {
    Name       = each.value
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_codebuild_webhook" "github" {
  for_each     = aws_codebuild_project.github
  project_name = each.value.name
  build_type   = "BUILD"
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "WORKFLOW_JOB_QUEUED"
    }
  }
}

resource "aws_cloudwatch_log_group" "github" {
  name              = "/${var.system_name}/${var.env_type}/codebuild"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/codebuild"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "github" {
  name                  = "${var.system_name}-${var.env_type}-github-actions-codebuild-iam-role"
  description           = "CodeBuild service IAM role for GitHub Actions"
  force_detach_policies = var.iam_role_force_detach_policies
  path                  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCodeBuildServiceToAssumeRole"
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name = "${var.system_name}-${var.env_type}-github-actions-codebuild-iam-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        [
          {
            Sid      = "AllowDescribeLogGroups"
            Effect   = "Allow"
            Action   = ["logs:DescribeLogGroups"]
            Resource = ["arn:aws:logs:${local.region}:${local.account_id}:log-group:*"]
          },
          {
            Sid    = "AllowLogStreamAccess"
            Effect = "Allow"
            Action = [
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams"
            ]
            Resource = ["${aws_cloudwatch_log_group.github.arn}:*"]
          }
        ],
        (
          var.kms_key_arn != null ? [
            {
              Sid      = "AllowKMSDecrypt"
              Effect   = "Allow"
              Action   = ["kms:GenerateDataKey"]
              Resource = [var.kms_key_arn]
            }
          ] : []
        )
      )
    })
  }
  tags = {
    Name       = "${var.system_name}-${var.env_type}-github-actions-codebuild-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
