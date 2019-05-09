#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip

pip install -U pip
pip install ansible ansible==2.6

cat << EOF >> /etc/environment
HMPPS_ROLE="${app_name}"
HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${route53_sub_domain}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${route53_sub_domain}
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"

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

cat << EOF > ~/vars.yml
---

region: "${region}"
environment_name: "${environment_name}"
project_name: "${project_name}"
ndelius_version : "${ndelius_version}"

# AWS
cldwatch_log_group: "${cldwatch_log_group}"
s3_dependencies_bucket: "${s3_dependencies_bucket}"
s3_backups_bucket: "${s3_backups_bucket}"

# ApacheDS
jvm_mem_args: "${jvm_mem_args}"
apacheds_version: "${apacheds_version}"
apacheds_install_directory: "${apacheds_install_directory}"
apacheds_lib_directory: "${apacheds_lib_directory}"
workspace: "${workspace}"
log_level: "${log_level}"

# LDAP
ldap_protocol: "${ldap_protocol}"
ldap_port: "${ldap_port}"
bind_user: "${bind_user}"
partition_id: "${partition_id}"
base_root: "${base_root}"
is_consumer: ${is_consumer}
provider_host: "${provider_host}"

# Data import
import_users_ldif: "${import_users_ldif}"
sanitize_oid_ldif: "${sanitize_oid_ldif}"

EOF

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/vars.yml"
   - "{{ playbook_dir }}/users.yml"
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
'bind_password':'$bind_password'\
}"