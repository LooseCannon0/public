#!/bin/bash

# Ensure the script exits immediately if any command fails.
set -e

# Update and upgrade system
sudo apt-get update
sudo apt-get -y upgrade

# Set timezone to Detroit
sudo timedatectl set-timezone America/Detroit

# Allow passwordless sudo for current user
USER_NAME=$(whoami)
if ! sudo grep -q "^$USER_NAME ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/99_$USER_NAME
    sudo chmod 0440 /etc/sudoers.d/99_$USER_NAME
fi

# Install NFS tools
sudo apt-get install -y nfs-common

# Install Zabbix agent from system repository
sudo apt-get install -y zabbix-agent
# Enable and start Zabbix agent service
sudo systemctl enable zabbix-agent
sudo systemctl start zabbix-agent
# Configure Zabbix agent
ZABBIX_SERVER="192.168.57.15"  # Replace with your Zabbix server address
sudo sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/"  /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/"  /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/^# HostnameItem=.*/HostnameItem=system.hostname/"  /etc/zabbix/zabbix_agentd.conf

# Restart Zabbix agent service to apply changes
sudo systemctl restart zabbix-agent

echo "Base configuration complete."