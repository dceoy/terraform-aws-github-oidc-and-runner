resource "aws_codebuild_project" "github" {
  name         = local.codebuild_project_name
  description  = "CodeBuild project for GitHub Actions"
  service_role = aws_iam_role.github.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }
  source {
    type      = "NO_SOURCE"
    buildspec = <<-EOT
    ---
    version: 0.2
    phases:
      dummy:
        commands:
          - echo "This buildspec will be overridden by GitHub Actions"
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
      group_name = aws_cloudwatch_log_group.github.name
      status     = "ENABLED"
    }
  }
  build_timeout  = var.codebuild_build_timeout
  queued_timeout = var.codebuild_queued_timeout
  tags = {
    Name       = local.codebuild_project_name
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_cloudwatch_log_group" "github" {
  name              = "/${var.system_name}/${var.env_type}/codebuild/${local.codebuild_project_name}"
  retention_in_days = var.cloudwatch_logs_retention_in_days
  kms_key_id        = var.kms_key_arn
  tags = {
    Name       = "/${var.system_name}/${var.env_type}/codebuild/${local.codebuild_project_name}"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}

resource "aws_iam_role" "github" {
  name        = "${local.codebuild_project_name}-iam-role"
  description = "GitHub OIDC provider IAM role"
  path        = "/"
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
  managed_policy_arns = compact([
    var.use_ecr ? "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" : null
  ])
  inline_policy {
    name = "${local.codebuild_project_name}-iam-policy"
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
    Name       = "${local.codebuild_project_name}-iam-role"
    SystemName = var.system_name
    EnvType    = var.env_type
  }
}
