remote_state {
  backend = "s3"

  config = {
    encrypt        = true
    bucket         = "${get_env("TG_REMOTE_STATE_BUCKET", "")}"
    key            = "delius-core/${path_relative_to_include()}/terraform.tfstate"
    region         = "${get_env("TG_REGION", "")}"
    dynamodb_table = "${get_env("TG_ENVIRONMENT_IDENTIFIER", "")}-lock-table"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    optional_var_files = [
      "${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_COMMON_DIRECTORY", "")}/common.tfvars",
      "${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "")}/${get_env("TG_ENVIRONMENT_NAME", "")}.tfvars",
      "${get_parent_terragrunt_dir()}/env_configs/${get_env("TG_ENVIRONMENT_NAME", "")}/sub-projects/delius-core.tfvars"
    ]
  }

  extra_arguments "disable_input" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region  = "${get_env("TG_REGION", "")}"
  version = "~> 2.0"
}

provider "template" {
  version = "~> 2.0"
}
EOF
}