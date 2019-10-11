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
- name: nfs
  src: https://github.com/ministryofjustice/hmpps-nfs
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

# SPG
spg_jms_url: "${spg_jms_url}"
activemq_data_folder: "${activemq_data_folder}/data"

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

# NFS
is_nfs_client: true
nfs_mount_dir: "${activemq_data_folder}"
nfs_mount_owner: oracle
nfs_server_name: amq-nfs

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
     - nfs
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_initial_role}"
     - "{{ playbook_dir }}/.ansible/roles/${app_bootstrap_name}/roles/${app_bootstrap_secondary_role}"
     # - rsyslog
     # - elasticbeats
     # - tier specific role
EOF

# get ssm parameters
# TODO replace project name with sub-project name
PARAM=$(aws ssm get-parameters \
--region eu-west-2 \
--with-decryption --name \
"/${environment_name}/${project_name}/weblogic/${app_name}-domain/weblogic_admin_password" \
"/${environment_name}/${project_name}/delius-database/db/delius_pool_password" \
"/${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password" \
"/${environment_name}/${project_name}/umt/umt/delius_secret" \
"/${environment_name}/${project_name}/weblogic/${app_name}-domain/remote_broker_username" \
"/${environment_name}/${project_name}/weblogic/${app_name}-domain/remote_broker_password" \
--query Parameters)

# set parameter values
weblogic_admin_password="$(echo $PARAM | jq '.[] | select(.Name | test("weblogic_admin_password")) | .Value' --raw-output)"
ldap_admin_password="$(echo $PARAM | jq '.[] | select(.Name | test("ldap_admin_password")) | .Value' --raw-output)"
database_password="$(echo $PARAM | jq '.[] | select(.Name | test("delius_pool_password")) | .Value' --raw-output)"
usermanagement_secret="$(echo $PARAM | jq '.[] | select(.Name | test("delius_secret")) | .Value' --raw-output)"
remote_broker_username="$(echo $PARAM | jq '.[] | select(.Name | test("remote_broker_username")) | .Value' --raw-output)"
remote_broker_password="$(echo $PARAM | jq '.[] | select(.Name | test("remote_broker_password")) | .Value' --raw-output)"


export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml \
--extra-vars "{\
'instance_id':'$INSTANCE_ID', \
'weblogic_admin_password':'$weblogic_admin_password', \
'ldap_admin_password':'$ldap_admin_password', \
'database_password':'$database_password', \
'usermanagement_secret':'$usermanagement_secret', \
'activemq_remoteCF_username':'$remote_broker_username', \
'activemq_remoteCF_password':'$remote_broker_password' \
}"
