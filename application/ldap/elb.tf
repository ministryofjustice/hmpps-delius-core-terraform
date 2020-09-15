resource "aws_elb" "lb" {
  name     = "${var.short_environment_name}-ldap-lb"
  internal = true
  subnets = [
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az2,
    data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az3,
  ]
  tags            = merge(var.tags, { "Name" = "${var.environment_name}-ldap-lb" })
  security_groups = [data.terraform_remote_state.delius_core_security_groups.outputs.sg_apacheds_ldap_private_elb_id]
  listener {
    instance_port     = var.ldap_ports["ldap"]
    instance_protocol = "tcp"
    lb_port           = var.ldap_ports["ldap"]
    lb_protocol       = "tcp"
  }
  health_check {
    target              = "HTTP:80/is-primary"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 15
    interval            = 30
  }
}

