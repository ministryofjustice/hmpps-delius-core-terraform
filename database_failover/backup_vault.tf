# The Oracle Backup Vault is *** NOT *** used for routine BAU Backups of the Database
# (These are RMAN backups to S3)
#
# Instead these are used only for keeping AWS Snapshots of EC2 Instances hosting
# Database ahead of any particularly disruptive activites such as
# patching and upgrades, or major EBS changes, as a secondary form of failback
#
# Therefore NO backup plan is associated with this vault as it is used only
# on an adhoc basis
#

resource "aws_backup_vault" "oracle_backup_vault" {
  name        = "${var.short_environment_identifier}-oracle-backup-vault"
  kms_key_arn = data.terraform_remote_state.key_profile.outputs.kms_arn_app
  tags = merge(
    var.tags,
    {
      "Name" = "${var.short_environment_identifier}-oracle-backup-vault"
    },
  )
}