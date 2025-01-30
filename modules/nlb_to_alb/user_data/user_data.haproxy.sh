#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log | logger -t user-data) 2>&1
echo BEGIN
date '+%Y-%m-%d %H:%M:%S'

yum install -y wget git python-pip
pip install -U pip
pip install ansible ansible==2.6

cat <<EOF >>/etc/environment
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="$(curl http://169.254.169.254/latest/meta-data/instance-id).${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
export REGION="${region}"
EOF
## Ansible runs in the same shell that has just set the env vars for future logins so it has no knowledge of the vars we've
## just configured, so lets export them
export HMPPS_ROLE="${app_name}"
export HMPPS_FQDN="$(curl http://169.254.169.254/latest/meta-data/instance-id).${private_domain}"
export HMPPS_STACKNAME="${env_identifier}"
export HMPPS_STACK="${short_env_identifier}"
export HMPPS_ENVIRONMENT="${route53_sub_domain}"
export HMPPS_ACCOUNT_ID="${account_id}"
export HMPPS_DOMAIN="${private_domain}"
export INSTANCE_ID="$(curl http://169.254.169.254/latest/meta-data/instance-id)"
export REGION="${region}"

cat <<EOF >~/requirements.yml
---
##
# ${app_name}
##

- name: bootstrap
  src: https://github.com/ministryofjustice/hmpps-bootstrap
  version: centos
- name: users
  src: https://github.com/singleplatform-eng/ansible-users

EOF

/usr/bin/curl -o ~/users.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-delius-ansible/master/group_vars/${bastion_inventory}.yml
/usr/bin/curl -o ~/delius-core.yml https://raw.githubusercontent.com/ministryofjustice/hmpps-env-configs/master/${route53_sub_domain}/ansible/group_vars/all.yml

cat <<EOF >~/bootstrap.yml
---

- hosts: localhost
  vars_files:
   - "{{ playbook_dir }}/users.yml"
   - "{{ playbook_dir }}/delius-core.yml"
  roles:
     - bootstrap
     - users
EOF

export ANSIBLE_LOG_PATH=$HOME/.ansible.log

ansible-galaxy install -f -r ~/requirements.yml
CONFIGURE_SWAP=true ansible-playbook ~/bootstrap.yml

### Bodge to fix CentOS 7 repos ###
# Backup the existing repos
mkdir /etc/yum.repos.d/backup
mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/backup
mv /etc/yum.repos.d/epel* /etc/yum.repos.d/backup

# Create new repo config targetting archives
tee /etc/yum.repos.d/CentOS-Vault.repo <<EOF
[base]
name=CentOS-7 - Base
baseurl=http://vault.centos.org/centos/7/os/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-7 - Updates
baseurl=http://vault.centos.org/centos/7/updates/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-7 - Extras
baseurl=http://vault.centos.org/centos/7/extras/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF

tee /etc/yum.repos.d/epel-archive.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch (Archive)
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/\$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-debuginfo]
name=Extra Packages for Enterprise Linux 7 - \$basearch - Debug (Archive)
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/\$basearch/debug/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

[epel-source]
name=Extra Packages for Enterprise Linux 7 - \$basearch - Source (Archive)
baseurl=https://archives.fedoraproject.org/pub/archive/epel/7/SRPMS/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
EOF


# Import SCLo key
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo

# Clean and update the package cache
yum clean all
yum makecache

# Install HAProxy
yum install -y rh-haproxy18-haproxy rh-haproxy18-haproxy-syspaths

# Configure HAProxy
mv /etc/opt/rh/rh-haproxy18/haproxy/haproxy.cfg /etc/opt/rh/rh-haproxy18/haproxy/haproxy.cfg.orig
cat <<EOF >>/etc/opt/rh/rh-haproxy18/haproxy/haproxy.cfg
${haproxy_cfg}
EOF

# Start HAProxy
systemctl start rh-haproxy18-haproxy
systemctl enable rh-haproxy18-haproxy
