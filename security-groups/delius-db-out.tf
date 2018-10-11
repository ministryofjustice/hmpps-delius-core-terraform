# delius-db-out.tf

################################################################################
## delius_db_out
################################################################################
resource "aws_security_group" "delius_db_out" {
  name        = "${var.environment_name}-delius-db-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database out"
  tags        = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-delius-db-out", "Type", "DB"))}"

  lifecycle {
    create_before_destroy = true
  }
}

output "sg_delius_db_out_id" {
  value = "${aws_security_group.delius_db_out.id}"
}
