# Create a dedicated security group with no ingress for the batch compute environment
# Requires egress for pulling images from container registry and connection to p-nomis and delius endpoints
resource "aws_security_group" "delius_dss_out" {
  name        = "${var.environment_name}-delius-dss-out"
  vpc_id      = "${data.terraform_remote_state.vpc.vpc_id}"
  description = "Delius database in"
  tags        = "${merge(var.tags, map("Name", "${var.environment_name}-delius-dss-out", "Type", "Private"))}"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sg_delius_dss_out_id" {
  value = "${aws_security_group.delius_dss_out.id}"
}