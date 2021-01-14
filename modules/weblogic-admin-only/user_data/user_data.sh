#!/bin/bash
set -ex


# Output to stdout, file, and syslog
exec > >(tee /var/log/user-data.log | tee >(logger --tag user-data --stderr 2>/dev/console)) 2>&1 # see https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-log-user-data/
echo "Started at $(date '+%Y-%m-%d %H:%M:%S')"


# Install dependencies
yum install -y python-pip
python -m pip install --upgrade pip
python -m pip install ansible==2.6.*


# Configure environment
cat << EOF >> /etc/environment
export HMPPS_ROLE="${tier_name}"
export HMPPS_FQDN="$(curl http://169.254.169.254/latest/meta-data/instance-id).${private_domain}"
export HMPPS_STACKNAME="${environment_identifier}"
export HMPPS_STACK="${short_environment_identifier}"
export HMPPS_ENVIRONMENT="${environment_name}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
export REGION="${region}"
EOF
. /etc/environment
export ANSIBLE_LOG_PATH=~/bootstrap/ansible.log
export ANSIBLE_CONFIG=~/bootstrap/hmpps-env-configs/ansible/ansible.cfg
export CONFIGURE_SWAP=true


# Fetch bootstrap configuration
mkdir -p ~/bootstrap
git clone https://github.com/ministryofjustice/hmpps-env-configs.git ~/bootstrap/hmpps-env-configs || echo 'WARNING: hmpps-env-configs already exists'
curl --silent --fail --show-error --output ~/bootstrap/users.yml "https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml"
cat << EOF > ~/bootstrap/requirements.yml
---
- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users
  version: v1.2.6
- name: delius-core
  src: "${app_bootstrap_src}"
  version: "${app_bootstrap_version}"
EOF
cat << EOF > ~/bootstrap/vars.yml
tier_name: "${tier_name}"
instance_id: "{{ lookup('env', 'INSTANCE_ID') }}"
remote_user_filename: "${bastion_inventory}"
${ansible_vars_yml}
EOF
cat << EOF > ~/bootstrap/playbook.yml
- hosts: localhost
  vars_files:
    - ~/bootstrap/vars.yml
    - ~/bootstrap/users.yml
  roles:
    - bootstrap
    ${indent(4, ansible_roles_yml)}
    - users
EOF


# Download and apply Ansible roles
ansible-galaxy install --force --role-file ~/bootstrap/requirements.yml
ansible-playbook --connection local \
 --inventory "~/bootstrap/hmpps-env-configs/ansible" \
 --inventory "~/bootstrap/hmpps-env-configs/${environment_name}/ansible" \
 ~/bootstrap/playbook.yml