locals {
  repo_root = get_repo_root()
  env_vars  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  extra_arguments "parallelism" {
    commands = get_terraform_commands_that_need_parallelism()
    arguments = [
      "-parallelism=2"
    ]
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.env_vars.locals.terraform_s3_bucket
    key            = "${basename(local.repo_root)}/${local.env_vars.locals.system_name}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.env_vars.locals.region
    encrypt        = true
    dynamodb_table = local.env_vars.locals.terraform_dynamodb_table
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.env_vars.locals.region}"
  default_tags {
    tags = {
      SystemName = "${local.env_vars.locals.system_name}"
      EnvType    = "${local.env_vars.locals.env_type}"
    }
  }
}
EOF
}

catalog {
  urls = [
    "${local.repo_root}/modules/oidc",
    "${local.repo_root}/modules/kms",
    "${local.repo_root}/modules/codebuild"
  ]
}

inputs = {
  system_name                                       = local.env_vars.locals.system_name
  env_type                                          = local.env_vars.locals.env_type
  create_kms_key                                    = false
  kms_key_deletion_window_in_days                   = 30
  kms_key_rotation_period_in_days                   = 365
  enable_github_oidc                                = false
  github_repositories_requiring_oidc                = ["dceoy/*"]
  github_iam_oidc_provider_iam_policy_arns          = ["arn:aws:iam::aws:policy/PowerUserAccess"]
  iam_role_force_detach_policies                    = true
  github_repositories_requiring_codebuild           = ["dceoy/terraform-aws-github-oidc-and-runner"]
  cloudwatch_logs_retention_in_days                 = 30
  codebuild_environment_type                        = "LINUX_CONTAINER"
  codebuild_environment_compute_type                = "BUILD_GENERAL1_SMALL"
  codebuild_environment_image                       = "aws/codebuild/standard:7.0"
  codebuild_environment_image_pull_credentials_type = "CODEBUILD"
  codebuild_environment_privileged_mode             = false
  codebuild_build_timeout                           = 5
  codebuild_queue_timeout                           = 5
  # github_enterprise_slug                            = null
}
