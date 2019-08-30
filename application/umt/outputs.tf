output "asg" {
  value = {
    id = "${aws_autoscaling_group.asg.id}"
    arn = "${aws_autoscaling_group.asg.arn}"
  }
}