#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

# Setup ECS
echo "ECS_CLUSTER=${ecs_cluster_name}" >> /etc/ecs/ecs.config
service docker start
start ecs

# Install ansible
sudo -i
yum install -y git wget yum-utils
easy_install pip
PATH=/usr/local/bin:$PATH
pip install ansible==2.6 virtualenv awscli boto botocore boto3

# Download user inventory and run ansible
/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/dev.yml
sed -i '/users_deleted:/,$d' ~/users.yml
cat << EOF > ~/requirements.yml
---

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users
EOF
cat << EOF > ~/bootstrap-users.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/users.yml"
  roles:
     - bootstrap
     - users
EOF
cat << EOF > /etc/sudoers.d/webops
# Members of the webops group may gain root privileges
%webops ALL=(ALL) NOPASSWD:ALL

Defaults  use_pty, log_host, log_year, logfile="/var/log/webops.sudo.log"
EOF

ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap-users.yml