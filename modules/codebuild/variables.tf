variable "system_name" {
  description = "System name"
  type        = string
  default     = "gha"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "github_repositories_requiring_codebuild" {
  description = "GitHub repositories requiring CodeBuild"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for r in var.github_repositories_requiring_codebuild : can(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+[*]?|\\*)$", r))
    ])
    error_message = "GitHub repositories must be in the format 'organization/repository'"
  }
}

variable "github_enterprise_slug" {
  description = "GitHub Enterprise slug"
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN"
  type        = string
  default     = null
}

variable "cloudwatch_logs_retention_in_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 30
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_in_days)
    error_message = "CloudWatch Logs retention in days must be 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 or 0 (zero indicates never expire logs)"
  }
}

variable "codebuild_environment_type" {
  description = " CodeBuild environment type"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "codebuild_environment_compute_type" {
  description = "Compute type for CodeBuild environment"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_environment_image" {
  description = "Image for CodeBuild environment"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}

variable "codebuild_environment_image_pull_credentials_type" {
  description = "Type of image pull credentials to use for CodeBuild environment"
  type        = string
  default     = "CODEBUILD"
}

variable "codebuild_environment_privileged_mode" {
  description = "Whether to enable privileged mode for CodeBuild environment"
  type        = bool
  default     = false
}

variable "codebuild_build_timeout" {
  description = "Build timeout for CodeBuild project"
  type        = number
  default     = 5
  validation {
    condition     = var.codebuild_build_timeout >= 5 && var.codebuild_build_timeout <= 480
    error_message = "CodeBuild build timeout must be between 5 and 480 minutes"
  }
}

variable "codebuild_queued_timeout" {
  description = "Queued timeout for CodeBuild project"
  type        = number
  default     = 5
  validation {
    condition     = var.codebuild_queued_timeout >= 5 && var.codebuild_queued_timeout <= 480
    error_message = "CodeBuild queued timeout must be between 5 and 480 minutes"
  }
}
