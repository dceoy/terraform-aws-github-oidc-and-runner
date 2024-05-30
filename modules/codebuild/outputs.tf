output "codebuild_project_id" {
  description = "CodeBuild project ID"
  value       = aws_codebuild_project.github.id
}

output "codebuild_cloudwatch_logs_log_group_name" {
  description = "CodeBuild CloudWatch Logs log group name"
  value       = aws_cloudwatch_log_group.github.name
}

output "codebuild_execution_iam_role_arn" {
  description = "CodeBuild execution IAM role ARN"
  value       = aws_iam_role.github.arn
}
