include "root" {
  path = find_in_parent_folders()
}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    kms_key_arn = null
  }
  mock_outputs_merge_strategy_with_state = "shallow"
}

inputs = {
  kms_key_arn = dependency.kms.outputs.kms_key_arn
}

terraform {
  source = "${get_repo_root()}/modules/codebuild"
}
