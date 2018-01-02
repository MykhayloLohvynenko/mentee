#!/bin/bash
set -eu

USER="ansible"
PASSWORD="ansiblepass"

# Add user 
# TODO: Check user  !
sudo useradd $USER$

# Install password
# sudo echo "$USER:$PASSWORD" | chpasswd

#ADD NEW USER TO SUDOERS FILE
# TODO: Grep file before add this string

sudo echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Copy ssh key for ansible user
# ssh-copy-id

