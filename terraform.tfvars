terragrunt = {
  # Configure Terragrunt to automatically store tfstate files in S3
  remote_state = {
    backend = "s3"

    config {
      encrypt = true
      bucket  = "${get_env("TG_REMOTE_STATE_BUCKET", "REMOTE_STATE_BUCKET")}"
      key     = "delius-core/${path_relative_to_include()}/terraform.tfstate"
      region  = "${get_env("TG_REGION", "AWS-REGION")}"

      dynamodb_table = "${get_env("TG_ENVIRONMENT_IDENTIFIER", "ENVIRONMENT_IDENTIFIER")}-lock-table"
    }
  }

  terraform {
    extra_arguments "common_vars" {
      commands = [
        "destroy",
        "plan",
        "import",
        "push",
        "refresh",
      ]

      arguments = [
        "-var-file=${get_parent_tfvars_dir()}/env_configs/common/common.tfvars",
        "-var-file=${get_parent_tfvars_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "integration")}/${get_env("TG_ENVIRONMENT_NAME", "integration")}.tfvars",
        "-var-file=${get_parent_tfvars_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "ENVIRONMENT")}/sub-projects/delius-core.tfvars",
      ]
    }
  }
}
