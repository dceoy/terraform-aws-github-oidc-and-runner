data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  codebuild_project_names = {
    for r in var.github_repositories_requiring_codebuild : r => "${var.system_name}-${var.env_type}-codebuild-project-for-${replace(r, "/", "-")}"
  }
}
