output "instance_profile_ec2_id" {
  value = "${aws_iam_instance_profile.ec2.id}"
}

output "instance_profile_ec2_arn" {
  value = "${aws_iam_instance_profile.ec2.arn}"
}

output "instance_profile_ec2" {
  value = {
    id  = "${aws_iam_instance_profile.ec2.id}",
    arn = "${aws_iam_instance_profile.ec2.arn}"
  }
}
