# Load runner host

resource "aws_instance" "loadrunner" {
  ami                         = "${data.aws_ami.centos_docker.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${data.terraform_remote_state.vpc.vpc_private-subnet-az1}"
  associate_public_ip_address = false
  key_name                    = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile        = "${data.terraform_remote_state.key_profile.instance_profile_ec2_id}"
  user_data                   = "${data.template_file.user_data.rendered}"
  tags                        = "${merge(var.tags, map("Name", "${data.terraform_remote_state.vpc.environment_name}-loadrunner"))}"

  vpc_security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_common_out_id}",
  ]
  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }


  lifecycle {
    ignore_changes = ["ami", "user_data"]
  }
}

resource "aws_route53_record" "loadrunner_instance_internal" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  name    = "loadrunner"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.loadrunner.private_ip}"]
}

resource "aws_route53_record" "loadrunner_instance_public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  name    = "loadrunner"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.loadrunner.private_ip}"]
}

output "internal_fqdn_loadrunner" {
  value = "${aws_route53_record.loadrunner_instance_internal.fqdn}"
}

output "public_fqdn_loadrunner" {
  value = "${aws_route53_record.loadrunner_instance_public.fqdn}"
}

output "private_ip_loadrunner" {
  value = "${aws_instance.loadrunner.private_ip}"
}
