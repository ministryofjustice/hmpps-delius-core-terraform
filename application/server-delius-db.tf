resource "aws_instance" "delius_db" {
  ami                  = "${data.aws_ami.centos_oracle_db.id}"
  instance_type        = "${var.instance_type_db}"
  subnet_id            = "${data.terraform_remote_state.vpc.vpc_db-subnet-az1}"
  key_name             = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  iam_instance_profile = "${module.s3_access_role.instance_profile_ec2_id}"
  source_dest_check    = false

  vpc_security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_delius_db_in_id}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-delius-db"))}"

  lifecycle {
    ignore_changes = ["ami"]
  }
}

resource "aws_ebs_volume" "delius_db_xvdc" {
  availability_zone = "${aws_instance.delius_db.availability_zone}"
  type              = "io1"
  iops              = 1000
  size              = 50
  encrypted         = true
  kms_key_id        = "${module.kms_key_app.kms_arn}"
  tags              = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-delius-db-xvdc"))}"
}

resource "aws_volume_attachment" "delius_db_xvdc" {
  device_name  = "/dev/xvdc"
  instance_id  = "${aws_instance.delius_db.id}"
  volume_id    = "${aws_ebs_volume.delius_db_xvdc.id}"
  force_detach = true
}

resource "aws_ebs_volume" "delius_db_xvdd" {
  availability_zone = "${aws_instance.delius_db.availability_zone}"
  type              = "io1"
  iops              = 1000
  size              = 50
  encrypted         = true
  kms_key_id        = "${module.kms_key_app.kms_arn}"
  tags              = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-delius-db-xvdd"))}"
}

resource "aws_volume_attachment" "delius_db_xvdd" {
  device_name  = "/dev/xvdd"
  instance_id  = "${aws_instance.delius_db.id}"
  volume_id    = "${aws_ebs_volume.delius_db_xvdd.id}"
  force_detach = true
}

resource "aws_route53_record" "delius_db_internal" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  name    = "delius-db"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.delius_db.private_ip}"]
}

resource "aws_route53_record" "delius_db_public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  name    = "delius-db"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.delius_db.private_ip}"]
}
