data "aws_caller_identity" "current" {}

data "terraform_remote_state" "delius_core_security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/security-groups/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "delius_api" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "delius-core/application/delius-api/terraform.tfstate"
    region = var.region
  }
}

# This is a placeholder zip file to allow the Lambda functions to be created. It will be replaced by the real zip file
# as part of the Lambda deployment process.
data "archive_file" "placeholder_python_package" {
  type        = "zip"
  output_path = "${path.module}/files/placeholder-python.zip"
  source {
    filename = "main.py"
    content  = <<-EOF
    def handler(event, context):
        return 0
    EOF
  }
}

data "archive_file" "placeholder_nodejs_package" {
  type        = "zip"
  output_path = "${path.module}/files/placeholder-nodejs.zip"
  source {
    filename = "index.js"
    content  = <<-EOF
    exports.handler = async function(event, context) {
      return 0
    }
    EOF
  }
}
