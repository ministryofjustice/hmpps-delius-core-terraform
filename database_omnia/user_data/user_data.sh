#!/usr/bin/env bash
set -x

yum install -y wget git python-pip amazon-ssm-agent
pip install -U pip
pip install ansible

# log bootstrap after creds obtained
touch /var/log/user-data.log
chmod 600 /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

cat << EOF >> /etc/environment
export HMPPS_FQDN="${server_name}.${private_domain}"
export HMPPS_STACKNAME=${env_identifier}
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_FQDN="${server_name}.${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="`curl http://169.254.169.254/latest/meta-data/instance-id`"
export REGION="${region}"

cat << EOF > ~/requirements.yml
---

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: singleplatform-eng.users

EOF

/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml

cat << EOF >> ~/.bash_profile

alias getenv='. /etc/environment && cat /etc/environment'
alias tailudl='tail -n 100 -F /var/log/user-data.log'
alias udl='less +G /var/log/user-data.log'
alias ud='less /var/lib/cloud/instance/user-data.txt'
alias src='. ~/.bash_profile'
EOF

cat << EOF > ~/vars.yml
region: "${region}"

# For user_update cron
remote_user_filename: "${bastion_inventory}"

mount_points:
  - mount_point: "/data"
    device_name: "/dev/xvdca"
  - mount_point: "/software"
    device_name: "/dev/xvdcb"

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
EOF

cat << EOF > ~/runboot.sh
#!/usr/bin/env bash

export ANSIBLE_LOG_PATH=\$HOME/.ansible.log
ansible-galaxy install -f -r ~/requirements.yml
ansible-playbook ~/bootstrap.yml -v
EOF
chmod u+x ~/runboot.sh

export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true SELF_REGISTER=true ansible-playbook ~/bootstrap.yml -v

if [[ $? -eq 0 ]]
then
    ## allow Ansible jobs polling for readyness time to disconnect
   /sbin/shutdown -r +1 "Rebooting in 1 minute"
fi
