#!/bin/bash
set -eu

# This bash script was written for installation and configuration ansible.

# VARIABLES:

ANSIBLE_CONFIG="/etc/ansible/ansible.cfg"

# install ansible

sudo yum -y install ansible

# Modify ansible configuration file.
sudo cp /vagrant/shell/files/ansible.cfg $ANSIBLE_CONFIG

# sed -i '/\[defaults\]/a inventory = /vagrant/ansible/inventory' $ANSIBLE_CONFIG
# sed -i '/\[defaults\]/a host_key_checking = False' $ANSIBLE_CONFIG
# sed -i '/\[defaults\]/a remote_user = ansible' $ANSIBLE_CONFIG
# sed -i '/\[defaults\]/a private_key_file = /vagrant/keys/ansible' $ANSIBLE_CONFIG
# sed -i '/roles_path    = /etc/ansible/roles:/usr/share/ansible/roles/c\"roles_path    = /etc/ansible/roles:/usr/share/ansible/roles:/vagrant/ansible/roles:/"' $ANSIBLE_CONFIG