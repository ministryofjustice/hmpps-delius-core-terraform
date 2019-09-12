#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip

pip install -U pip
pip install ansible ansible==2.6

cat << EOF >> /etc/environment
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"

cat << EOF > ~/requirements.yml
---
##
# ${app_name}
##

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users
- name: "${app_bootstrap_name}"
  src: "${app_bootstrap_src}"
  version: "${app_bootstrap_version}"

# - name: rsyslog
#   src: https://github.com/ministryofjustice/hmpps-rsyslog-role
# - name: elasticbeats
#   src: https://github.com/ministryofjustice/hmpps-beats-monitoring
# - name: tier specific role
#   src: https://github.com/ministryofjustice/tier specific role

EOF

/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml

/usr/bin/curl -o ~/delius-core.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/all.yml

cat << EOF > ~/vars.yml
---

region: "${region}"
environment_name: "${environment_name}"
project_name: "${project_name}"

# AWS
cldwatch_log_group: "${cldwatch_log_group}"
s3_dependencies_bucket: "${s3_dependencies_bucket}"
s3_backups_bucket: "${s3_backups_bucket}"

# ApacheDS
workspace: "${workspace}"

# LDAP
ldap_protocol: "${ldap_protocol}"
ldap_port: "${ldap_port}"
bind_user: "${bind_user}"
base_root: "${base_root}"
base_users: "${base_users}"

# Data import
import_users_ldif: "${import_users_ldif}"
import_users_ldif_base_users: "${import_users_ldif_base_users}"
sanitize_oid_ldif: ${sanitize_oid_ldif}

# For user_update cron
remote_user_filename: "${bastion_inventory}"

EOF

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/vars.yml"
   - "{{ playbook_dir }}/users.yml"
   - "{{ playbook_dir }}/delius-core.yml"
  roles:
     - bootstrap
     - users
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}"
     # - rsyslog
     # - elasticbeats
     # - tier specific role
EOF

# get ssm parameters
# TODO replace project name with sub-project name
PARAM=$(aws ssm get-parameters \
--region eu-west-2 \
--with-decryption --name \
"/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password" \
--query Parameters)

# set parameter values
bind_password="$(echo $PARAM | jq '.[] | select(.Name | test("ldap_admin_password")) | .Value' --raw-output)"

export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
--extra-vars "{\
'instance_id':'$INSTANCE_ID', \
'bind_password':'$bind_password'\
}"
