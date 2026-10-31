locals {
  codebuild_project_names = {
    for r in var.github_repositories_requiring_codebuild : r => "${var.system_name}-${var.env_type}-codebuild-project-for-${replace(r, "/", "-")}"
  }
}
