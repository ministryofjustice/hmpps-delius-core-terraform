#!/bin/bash
echo 'Installing dependencies...'
apt-get update -y
apt-get install awscli gettext-base -y

echo 'Downloading PWM configuration...'
aws s3 cp "s3://${bucket}/${war_file}"    "$CATALINA_HOME/webapps/pwm.war"
aws s3 cp "s3://${bucket}/${config_file}" "${config_file}.tpl"

echo 'Subsituting environment variables and installing configuration...'
mkdir -p "$PWM_APPLICATIONPATH"
envsubst < "${config_file}.tpl" > "$PWM_APPLICATIONPATH/${config_file}" && rm "${config_file}.tpl"

echo 'Starting...'
catalina.sh run
