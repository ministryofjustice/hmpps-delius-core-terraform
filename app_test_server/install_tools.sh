#!/usr/bin/env bash

yum update -y
yum install epel-release -y
yum install python-pip -y

pip install pip --upgrade 
pip install awscli --upgrade
