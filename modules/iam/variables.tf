variable "system_name" {
  description = "System name"
  type        = string
  default     = "gho"
}

variable "env_type" {
  description = "Environment type"
  type        = string
  default     = "dev"
}

variable "github_repositories_requiring_oidc" {
  description = "GitHub repositories requiring OIDC"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for r in var.github_repositories_requiring_oidc : can(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+[*]?|\\*)$", r))
    ])
    error_message = "GitHub repositories must be in the format 'organization/repository'"
  }
}

variable "github_iam_oidc_provider_iam_policy_arns" {
  description = "IAM role policy ARNs for the GitHub IAM OIDC provider"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  validation {
    condition = alltrue([
      for arn in var.github_iam_oidc_provider_iam_policy_arns : can(regex("arn:aws:iam::[0-9]+:policy/[A-Za-z0-9_-]+"))
    ])
    error_message = "IAM role policy ARNs must be valid ARNs"
  }
}

variable "github_enterprise_slug" {
  description = "GitHub Enterprise slug"
  type        = string
  default     = null
}
