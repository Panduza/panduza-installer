#!/bin/bash

# ===================================================================
# PARAMETERS

CONFIGURATION="0.3.x"

ASSETS_URL="https://raw.githubusercontent.com/Panduza/panduza-installer/main/assets"

# ===================================================================

# --------------------------
# Get system
# 
id=`lsb_release -i`
id=`echo $id | cut -c17-`
ve=`lsb_release -r`
ve=`echo $ve | cut -c10-`
osv=`echo ${id}_${ve}`
echo ""
echo "==================================="
echo "= OS: [$osv]"
echo "==================================="
echo ""

# --------------------------
# Install specifics
# 
if [[ $osv == "Ubuntu_22.04" ]]; then
    
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update


    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $USER
    
    wget -N -P /usr/lib/udev/rules.d \
        ${ASSETS_URL}/85-brltty.rules
    
fi

# ---
mkdir -p /etc/panduza
wget -N -P /etc/panduza \
    ${ASSETS_URL}/docker-compose.yml

# ---
mkdir -p /etc/panduza/configs
wget -N -P /etc/panduza/configs \
    ${ASSETS_URL}/mosquitto.conf

# ---
wget -N -P /etc/systemd/system/ \
    ${ASSETS_URL}/panduza.service

# ---
systemctl enable panduza.service


