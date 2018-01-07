#!/bin/bash
set -eu

# This bash script was written for installation and configuration ansible.

# VARIABLES:

HOME_ANSIBLE="/vagrant/ansible"
ANSIBLE_CONFIG="/etc/ansible/ansible.cfg"

# install ansible

sudo yum -y install ansible

# Modify ansible configuration file.

cat >> $ANSIBLE_CONFIG << EOF
inventory = $HOME_ANSIBLE/inventory
host_key_checking = False
remote_user = ansible
private_key_file = $HOME_ANSIBLE/keys/ansible
EOF