
output "asg" {
  value = {
    "id"    = "${aws_autoscaling_group.wls_asg.id}",
    "arn"   = "${aws_autoscaling_group.wls_asg.arn}",
    "name"  = "${aws_autoscaling_group.wls_asg.name}",
  }
}

output "alb" {
  value = {
    "id"    = "${aws_lb.internal_alb.id}",
    "arn"   = "${aws_lb.internal_alb.arn}",
    "name"  = "${aws_lb.internal_alb.name}",
  }
}

output "private_fqdn_internal_alb" {
  value = "${aws_route53_record.internal_alb_private.fqdn}"
}

output "public_fqdn_internal_alb" {
  value = "${aws_route53_record.internal_alb_public.fqdn}"
}

output "newtech_webfrontend_targetgroup_arn" {
  value = "${aws_lb_target_group.newtechweb_target_group.arn}"
}

output "cloudwatch_log_group" {
  value = "${var.ansible_vars["cldwatch_log_group"]}"
}

output "umt_targetgroup_arn" {
  value = "${aws_lb_target_group.umt_target_group.arn}"
}
