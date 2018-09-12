#TODO: add oracle RDS for OID

resource "aws_instance" "oid_db" {
  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "${var.instance_type_db}"
  subnet_id         = "${data.terraform_remote_state.vpc.vpc_db-subnet-az1}"
  key_name          = "${data.terraform_remote_state.vpc.ssh_deployer_key}"
  source_dest_check = false

  vpc_security_group_ids = [
    "${data.terraform_remote_state.vpc_security_groups.sg_ssh_bastion_in_id}",
    "${data.terraform_remote_state.delius_core_security_groups.sg_oid_db_in_id}",
  ]

  root_block_device = {
    delete_on_termination = true
    volume_size = 50
    volume_type = "gp2"
  }

  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-oid-db"))}"

  lifecycle {
    ignore_changes = [ "ami" ]
  }
}

resource "aws_ebs_volume" "oid_db_xvdc" {
  availability_zone = "${aws_instance.oid_db.availability_zone}"
  type              = "gp2"
  size              = 200
  encrypted         = true
  kms_key_id        = "${module.kms_key_app.kms_arn}"
  tags = "${merge(data.terraform_remote_state.vpc.tags, map("Name", "${var.environment_name}-oid-db-xvdc"))}"
}

resource "aws_volume_attachment" "oid_db_xvdc" {
  device_name = "/dev/xvdc"
  instance_id = "${aws_instance.oid_db.id}"
  volume_id   = "${aws_ebs_volume.oid_db_xvdc.id}"
  force_detach = true
}

resource "aws_route53_record" "oid_db_internal" {
  zone_id = "${data.terraform_remote_state.vpc.private_zone_id}"
  name    = "oid-db"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.oid_db.private_ip}"]
}

resource "aws_route53_record" "oid_db_public" {
  zone_id = "${data.terraform_remote_state.vpc.public_zone_id}"
  name    = "oid-db"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.oid_db.private_ip}"]
}
