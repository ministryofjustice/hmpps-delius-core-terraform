data "aws_caller_identity" "current" {}

data "aws_lb" "monitoring_lb" {
  count = var.monitoring_lb_arn != "" ? 1 : 0
  arn   = var.monitoring_lb_arn
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "ecs-cluster/terraform.tfstate"
    region = var.region
  }
}

data "external" "current_task_definition" {
  # Fetch the currently assigned task definition, this is used when var.ignore_task_definition_changes is true.
  # We use an external data source (instead of ignore_changes) for this, as a workaround for: https://github.com/hashicorp/terraform/issues/24188
  program = ["sh", "-c", "aws ecs describe-services --cluster '${data.terraform_remote_state.ecs_cluster.outputs.shared_ecs_cluster_name}' --services '${local.name}-service' --region '${var.region}' --query '{arn: services[0].taskDefinition}' || echo {\"arn\":\"\"}"]
}
