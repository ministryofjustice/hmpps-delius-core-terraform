#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip jq
pip install -U pip
pip install ansible ansible==2.6

cat << EOF >> /etc/environment
HMPPS_ROLE="${app_name}"
HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
HMPPS_STACKNAME=${env_identifier}
HMPPS_STACK="${short_env_identifier}"
HMPPS_ENVIRONMENT=${environment_name}
HMPPS_ACCOUNT_ID="${account_id}"
HMPPS_DOMAIN="${private_domain}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="`curl http://169.254.169.254/latest/meta-data/instance-id`.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT=${environment_name}
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
ndelius_version : "${ndelius_version}"

setup_datasources: "${setup_datasources}"

s3_dependencies_bucket: "${s3_dependencies_bucket}"
database_host: "${database_host}"
alfresco_host: "${alfresco_host}"
alfresco_office_host: "${alfresco_office_host}"
spg_host: "${spg_host}"
oid_host: "${oid_host}"
ndelius_display_name: "${ndelius_display_name}"
ndelius_training_mode: "${ndelius_training_mode}"
ndelius_log_level: "${ndelius_log_level}"
ndelius_analytics_tag: "${ndelius_analytics_tag}"
newtech_search_url: "${newtech_search_url}"
newtech_pdfgenerator_url: "${newtech_pdfgenerator_url}"
usermanagement_url: "${usermanagement_url}"
nomis_url: "${nomis_url}"


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
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_initial_role}"
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_secondary_role}"
     # - rsyslog
     # - elasticbeats
     # - tier specific role
EOF

# get ssm parmaeters
PARAM=$(aws ssm get-parameters \
--region eu-west-2 \
--with-decryption --name \
"/${environment_name}/delius-core/weblogic/${app_name}-domain/weblogic_admin_password" \
"/${environment_name}/delius-core/weblogic/${app_name}-domain/remote_broker_username" \
"/${environment_name}/delius-core/weblogic/${app_name}-domain/remote_broker_password" \
"/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password" \
--query Parameters)

# set parameter values
weblogic_admin_password="$(echo $PARAM | jq '.[] | select(.Name | test("weblogic_admin_password")) | .Value' --raw-output)"
remote_broker_username="$(echo $PARAM | jq '.[] | select(.Name | test("remote_broker_username")) | .Value' --raw-output)"
remote_broker_password="$(echo $PARAM | jq '.[] | select(.Name | test("remote_broker_password")) | .Value' --raw-output)"
ldap_admin_password="$(echo $PARAM | jq '.[] | select(.Name | test("ldap_admin_password")) | .Value' --raw-output)"

export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
--extra-vars '\
"weblogic_admin_password":"$weblogic_admin_password", \
"activemq_remoteCF_username":"$remote_broker_username", \
"activemq_remoteCF_password":"$remote_broker_password", \
"ldap_admin_password":"$ldap_admin_password" \
'
