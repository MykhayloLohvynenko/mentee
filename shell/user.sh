#!/bin/bash
set -eu

USER="ansible"
PASSWORD="ansiblepass"
SSH_HOME="/home/$USER/.ssh"
SHARE="/vagrant"

# Add user 
# TODO: Check user  !
sudo useradd $USER

# Install password
# sudo echo "$USER:$PASSWORD" | chpasswd

#ADD NEW USER TO SUDOERS FILE
# TODO: Grep file before add this string

sudo echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Copy ssh key for ansible user
sudo -u $USER -H mkdir $SSH_HOME
sudo cp $SHARE/keys/authorized_keys $SSH_HOME/

sudo chown -R $USER:$USER $SSH_HOME
sudo chmod 600 $SSH_HOME/authorized_keys
