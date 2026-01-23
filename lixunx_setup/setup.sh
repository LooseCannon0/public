#!/bin/bash

# Run on server:
# curl -s https://raw.githubusercontent.com/LooseCannon0/public/refs/heads/main/lixunx_setup/setup.sh | bash

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
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo dpkg -i zabbix-release_7.0-2+ubuntu24.04_all.deb
sudo apt update
sudo apt install -y zabbix-agent2
# Enable and start Zabbix agent service
sudo systemctl enable zabbix-agent2
sudo systemctl start zabbix-agent2
# Configure Zabbix agent
ZABBIX_SERVER="192.168.57.15"  # Replace with your Zabbix server address
sudo sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/"  /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/"  /etc/zabbix/zabbix_agent2.conf
sudo sed -i "s/^# HostnameItem=.*/HostnameItem=system.hostname/"  /etc/zabbix/zabbix_agent2.conf

# Restart Zabbix agent service to apply changes
sudo systemctl restart zabbix-agent2

echo "Base configuration complete."
