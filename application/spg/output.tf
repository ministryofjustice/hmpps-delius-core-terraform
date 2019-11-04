output "cloudwatch_log_group" {
  value = "${module.spg.cloudwatch_log_group}"
}

output "asg" {
  value = "${module.spg.asg}"
}

output "alb" {
  value = "${module.spg.alb}"
}