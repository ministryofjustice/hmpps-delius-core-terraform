# Create the AWS Batch Compute Environment and Job Queue from generic module
module "dss_batch_environment" {
  source         = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//batch//standalone_ce"
  ce_name        = "${var.environment_name}-ndelius"
  ce_instances   = "${var.dss_batch_instances}"
  ce_min_vcpu    = "${var.dss_min_vcpu}"
  ce_max_vcpu    = "${var.dss_max_vcpu}"
  ce_sg          = ["${aws_security_group.delius_dss_out.id}"]
  ce_queue_state = "${var.dss_queue_state}"

  ce_subnets = "${list(
    data.terraform_remote_state.vpc.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.vpc_private-subnet-az3,
  )}"

  ce_tags = "${merge(var.tags, map("Name", "${var.environment_name}-delius-dss-ce", "Type", "DB"))}"
}

# Create dedicated IAM Role and policy for DSS batch job
data "template" "dss_job_role_policy_template" {
  template = "${file("./templates/iam_policies/dss_job_role.tpl")}"

  vars {
    # List of SSM Parameters the batch instances are permitted to get, incl KMS keys to decrypt with
    dss_batch_ssm_resources = []
  }
}

data "template" "ec2_assume_role_template" {
  template = "${file("./templates/batch_jobs/dss.tpl")}"

  vars {}
}

resource "aws_iam_role" "dss_job_role" {
  name               = "batch_job_role"
  assume_role_policy = "${data.template.ec2_assume_role_template.rendered}"
}

resource "aws_iam_role_policy" "dss_job_policy" {
  name = "batch_sts_policy"
  role = "${aws_iam_role.dss_job_role.name}"

  policy = "${data.template.dss_job_role_policy_template.rendered}"
}

# Create DSS specific AWS Batch Job Definition
# Job Defintion is specific to DSS so not modularised
data "template_file" "dss_job_def_template" {
  template = "${file("./templates/batch_jobs/dss.tpl")}"

  vars {
    job_image  = "${var.dss_job_image}"
    job_role   = "${aws_iam_role.dss_job_role.arn}"
    job_memory = "${var.dss_job_memory}"
    job_vcpus  = "${var.dss_job_vcpus}"

    # Map of environment vars - e.g. dss config params
    job_envvars = "${var.dss_job_envvars}"

    # Job specific ulimits
    job_ulimits = "${var.dss_job_ulimits}"
  }
}

resource "aws_batch_job_definition" "dss_job_def" {
  name = "${var.environment_name}-ndelius-dss-job"
  type = "container"

  retry_strategy {
    attempts = "${var.dss_job_retries}"
  }

  # Rendered Job Definition from template
  container_properties = "${data.template_file.dss_job_def_template.rendered}"
}

# Create Cloudwatch Event (Scheduled) trigger from generic module
module "dss_cloudwatch_event" {
  source              = "git::https://github.com/ministryofjustice/hmpps-terraform-modules.git?ref=master//modules//cloudwatch//scheduled_event"
  event_name          = "${var.environment_name}-ndelius-dss-event"
  event_desc          = "Daily scheduled DSS Batch Event"
  event_schedule      = "${var.dss_job_schedule}"
  event_job_queue_arn = "${module.dss_batch_environment.job_queue_arn}"
  event_job_def_id    = "${aws_batch_job_definition.dss_job_def.id}"
  event_job_attempts  = "${var.dss_job_retries}"
}
