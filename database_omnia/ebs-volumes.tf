resource "aws_ebs_volume" "xvdca" {
  availability_zone = aws_instance.omnia_db.availability_zone
  type              = "gp3"
  size              = 1000
  encrypted         = true
  kms_key_id        = local.kms_key_id
  tags = merge({
    device_name   = "/dev/xvdca"
    Database      = local.server_name
  }, var.tags)
}

resource "aws_volume_attachment" "xvdca" {
  device_name  = "/dev/xvdca"
  instance_id  = aws_instance.omnia_db.id
  volume_id    = aws_ebs_volume.xvdca.id
  force_detach = true
}

resource "aws_ebs_volume" "xvdcb" {
  availability_zone = aws_instance.omnia_db.availability_zone
  type              = "gp3"
  size              = 500
  encrypted         = true
  kms_key_id        = local.kms_key_id
  tags = merge({
    device_name   = "/dev/xvdcb"
    Database      = local.server_name
  }, var.tags)
}

resource "aws_volume_attachment" "xvdcb" {
  device_name  = "/dev/xvdcb"
  instance_id  = aws_instance.omnia_db.id
  volume_id    = aws_ebs_volume.xvdcb.id
  force_detach = true
}
