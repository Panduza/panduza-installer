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
    wget -P /usr/lib/udev/rules.d \
        ${ASSETS_URL}/85-brltty.rules
fi

# ---
mkdir -p /etc/panduza
wget -P /etc/panduza \
    ${ASSETS_URL}/docker-compose.yml

# ---
mkdir -p /etc/panduza/configs
wget -P /etc/panduza/configs \
    ${ASSETS_URL}/mosquitto.conf

# ---
wget -P /etc/systemd/system/ \
    ${ASSETS_URL}/panduza.service

# ---
systemctl enable panduza.service


