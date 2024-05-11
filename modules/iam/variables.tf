variable "github_repositories" {
  description = "GitHub repositories to be accessed by the IAM role"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for r in var.github_repositories : can(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+[*]?|\\*)$", r))
    ])
    error_message = "GitHub repositories must be in the format 'organization/repository'"
  }
}

variable "github_oidc_provider_iam_policy_arns" {
  description = "GitHub OIDC provider IAM policy ARNs"
  type        = list(string)
  default     = []
}

variable "github_enterprise_slug" {
  description = "GitHub Enterprise slug"
  type        = string
  default     = null
}
