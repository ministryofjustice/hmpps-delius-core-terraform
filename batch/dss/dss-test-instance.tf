
# Create the AWS Instance for testing
# resource "aws_instance" "test_instance" {
#   ami                         = data.aws_ami.amazon_ami.id
#   instance_type               = "m5.large"
#   subnet_id                   = data.terraform_remote_state.vpc.outputs.vpc_private-subnet-az1
#   associate_public_ip_address = false
#   key_name                    = data.terraform_remote_state.vpc.outputs.ssh_deployer_key
#   iam_instance_profile        = data.terraform_remote_state.key_profile.outputs.instance_profile_ec2_id
#   user_data                   = ""
#   tags = merge(
#     var.tags,
#     {
#       "Name" = "${data.terraform_remote_state.vpc.outputs.environment_name}-dss-test"
#     },
#   )
#   vpc_security_group_ids = [
#     data.terraform_remote_state.vpc_security_groups.outputs.sg_ssh_bastion_in_id,
#     data.terraform_remote_state.vpc_security_groups.outputs.sg_management_server_id,
#     data.terraform_remote_state.delius_core_security_groups.outputs.sg_common_out_id,
#   ]
#   root_block_device {
#     delete_on_termination = true
#     volume_size           = 30
#     volume_type           = "gp2"
#   }
#   lifecycle {
#     ignore_changes = [ami]
#   }
# }
