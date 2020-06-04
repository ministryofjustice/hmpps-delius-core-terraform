#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip jq
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
export HMPPS_ENVIRONMENT=${route53_sub_domain}
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

EOF

/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml

/usr/bin/curl -o ~/delius-core.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/all.yml

cat << EOF > ~/vars.yml
---

region: "${region}"
cldwatch_log_group: "${cldwatch_log_group}"

# Artefact locations
s3_dependencies_bucket: "${s3_dependencies_bucket}"

# Server/WebLogic config
domain_name: "${domain_name}"
server_name: "${server_name}"
jvm_mem_args: "${jvm_mem_args}"
server_params: "${server_params}"
weblogic_admin_username: "${weblogic_admin_username}"
server_listen_address: "${server_listen_address}"
server_listen_port: "${server_listen_port}"

# Database
setup_datasources: "${setup_datasources}"
primary_db_host: "${primary_db_host}"
database_url: "${database_url}"
database_min_pool_size: "${database_min_pool_size}"
database_max_pool_size: "${database_max_pool_size}"

# Alfresco
alfresco_host: "${alfresco_host}"
alfresco_port: "${alfresco_port}"
alfresco_office_host: "${alfresco_office_host}"
alfresco_office_port: "${alfresco_office_port}"

# LDAP
ldap_host: "${ldap_host}"
ldap_readonly_host: "${ldap_readonly_host}"
ldap_port: "${ldap_port}"
ldap_principal: "${ldap_principal}"
ldap_base: "${ldap_base}"
ldap_user_base: "${ldap_user_base}"
ldap_group_base: "${ldap_group_base}"

# NDelius application
ndelius_display_name: "${ndelius_display_name}"
ndelius_log_level: "${ndelius_log_level}"
ndelius_training_mode: "${ndelius_training_mode}"
ndelius_analytics_tag: "${ndelius_analytics_tag}"
ldap_passfile: "${ldap_passfile}"

# New tech
newtech_search_url: "${newtech_search_url}"
newtech_pdfgenerator_url: "${newtech_pdfgenerator_url}"
newtech_pdfgenerator_templates: "${newtech_pdfgenerator_templates}"
newtech_pdfgenerator_secret: "${newtech_pdfgenerator_secret}"

# User management tool
usermanagement_url: "${usermanagement_url}"

# NOMIS
nomis_url: "${nomis_url}"
nomis_client_id: "${nomis_client_id}"
nomis_client_secret: "${nomis_client_secret}"

# Password Reset Tool
password_reset_url: "${password_reset_url}"

# Approved Premises Tracker API
aptracker_api_errors_url: "${aptracker_api_errors_url}"

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
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_initial_role}"
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_secondary_role}"
EOF

## Cut down script for running the application bootstrap for dev purposes
cat << EOF > ~/devbootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/vars.yml"
   - "{{ playbook_dir }}/users.yml"
   - "{{ playbook_dir }}/delius-core.yml"
  roles:
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_initial_role}"
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_secondary_role}"
EOF

cat << EOF > ~/getcreds
#!/usr/bin/env bash
# get ssm parameters
# TODO replace project name with sub-project name
export PARAM=\$(aws ssm get-parameters \
--region eu-west-2 \
--with-decryption --name \
"/${environment_name}/${project_name}/weblogic/${app_name}-domain/weblogic_admin_password" \
"/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password" \
"/${environment_name}/${project_name}/delius-database/db/delius_pool_password" \
"/${environment_name}/${project_name}/umt/umt/delius_secret" \
"/${environment_name}/${project_name}/aptracker_api/errors_ui/delius_secret" \
--query Parameters)
export weblogic_admin_password="\$(echo \$PARAM | jq '.[] | select(.Name | test("weblogic_admin_password")) | .Value' --raw-output)"
export ldap_admin_password="\$(echo \$PARAM | jq '.[] | select(.Name | test("ldap_admin_password")) | .Value' --raw-output)"
export database_password="\$(echo \$PARAM | jq '.[] | select(.Name | test("delius_pool_password")) | .Value' --raw-output)"
export usermanagement_secret="\$(echo \$PARAM | jq '.[] | select(.Name | test("umt/delius_secret")) | .Value' --raw-output)"

EOF
chmod u+x ~/getcreds

# Create boot script to allow for easier reruns if needed
cat << EOF > ~/runboot.sh
#!/usr/bin/env bash

. ~/getcreds
. /etc/environment
export ANSIBLE_LOG_PATH=\$HOME/.ansible.log
ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
   --extra-vars "{\
     'weblogic_admin_password':'\$weblogic_admin_password', \
     'ldap_admin_password':'\$ldap_admin_password', \
     'database_password':'\$database_password', \
     'usermanagement_secret':'\$usermanagement_secret', \
     'instance_id':'\$INSTANCE_ID', \
   }" \
   -b -vvvv
EOF
#
chmod u+x ~/runboot.sh

# Create boot script to allow for easier reruns if needed
cat << EOF > ~/devboot.sh
#!/usr/bin/env bash

. ~/getcreds
. /etc/environment
export ANSIBLE_LOG_PATH=\$HOME/.ansible.log
ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/devbootstrap.yml \
   --extra-vars "{\
     'weblogic_admin_password':'\$weblogic_admin_password', \
     'ldap_admin_password':'\$ldap_admin_password', \
     'database_password':'\$database_password', \
     'usermanagement_secret':'\$usermanagement_secret', \
     'instance_id':'\$INSTANCE_ID', \
   }" \
   -b -vvvv
EOF
#
chmod u+x ~/devboot.sh

# Run the boot script
~/runboot.sh
