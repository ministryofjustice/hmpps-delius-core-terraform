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
/usr/bin/curl -o ~/all.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/ansible/group_vars/all.yml
/usr/bin/curl -o ~/env-all.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/all.yml
/usr/bin/curl -o ~/env-ldap.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/ldap.yml

cat << EOF > ~/vars.yml
---

# Connection
ldap_port: "${ldap_port}"
bind_user: "${bind_user}"
# Structure
base_root: "${base_root}"
base_users: "${base_users}"
base_service_users: "${base_service_users}"
base_roles: "${base_roles}"
base_role_groups: "${base_role_groups}"
base_groups: "${base_groups}"
# Logging
log_level: "${log_level}"
cldwatch_log_group: "${cldwatch_log_group}"
# Backups
s3_backups_bucket: "${s3_backups_bucket}"
backup_frequency: "${backup_frequency}"
# Performance/tuning
query_time_limit: "${query_time_limit}"
db_max_size: "${db_max_size}"

# For user_update cron
remote_user_filename: "${bastion_inventory}"

EOF

cat << EOF > ~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/vars.yml"
   - "{{ playbook_dir }}/users.yml"
   - "{{ playbook_dir }}/all.yml"
   - "{{ playbook_dir }}/env-all.yml"
   - "{{ playbook_dir }}/env-ldap.yml"
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

/usr/bin/curl -o ~/ansible.cfg https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/ansible/ansible.cfg
export ANSIBLE_CONFIG=~/ansible.cfg
export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
--extra-vars "{\
'instance_id':'$INSTANCE_ID', \
'bind_password':'$bind_password'\
}"
