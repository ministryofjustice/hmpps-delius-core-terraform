data "aws_ami" "centos" {
  owners      = ["895523100917"]
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Base CentOS master *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.environment_name}"
  }
}

data "aws_kms_key" "master" {
  key_id = "alias/${var.environment_name}-master"
}

#TODO: ASG for managed should nightly cycle boxes