variable "system_name" {
  description = "System name"
  type        = string
}

variable "env_type" {
  description = "Environment type"
  type        = string
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any IAM policies the IAM role has before destroying it"
  type        = bool
  default     = true
}

variable "enable_github_oidc" {
  description = "Whether to enable GitHub OIDC"
  type        = bool
  default     = false
}

variable "github_repositories_requiring_oidc" {
  description = "GitHub repositories requiring OIDC"
  type        = map(list(string))
  default     = {}
  validation {
    condition = alltrue([
      for k, v in var.github_repositories_requiring_oidc : alltrue([
        for r in v : can(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+[*]?|\\*)$", r))
      ])
    ])
    error_message = "GitHub repositories must be in the format 'organization/repository'"
  }
}

variable "github_iam_oidc_provider_iam_policy_arns" {
  description = "IAM role policy ARNs for the GitHub IAM OIDC provider"
  type        = map(list(string))
  default     = {}
  validation {
    condition = alltrue([
      for k, v in var.github_iam_oidc_provider_iam_policy_arns : alltrue([
        for a in v : can(regex("arn:aws:iam::(aws|[0-9]+):policy/[A-Za-z0-9_-]+", a))
      ])
    ])
    error_message = "IAM role policy ARNs must be valid ARNs"
  }
}

variable "github_enterprise_slug" {
  description = "GitHub Enterprise slug"
  type        = string
  default     = null
}
