#!/bin/bash

# ===================================================================
# PARAMETERS

CONFIGURATION="0.1.1"

PYTHON_VENV_PATH=/usr/local/bin/panduza/venv

ASSETS_URL="https://raw.githubusercontent.com/Panduza/panduza-installer/0.1.x/assets"

PYTHON_MODULES=(
    numpy==1.24.2 \
    nicegui==1.3.1 \
    colorama==0.4.6 \
    paho-mqtt==1.6.1 \
    pyftdi==0.54.0 \
    pymodbus==3.3.2 \
    pyserial==3.5 \
    pyudev==0.24.0 \
    pyusb==1.2.1 \
    PyHamcrest==2.0.4 \
    "git+https://github.com/Panduza/panduza-py.git@0.1.0#egg=panduza&subdirectory=client/" \
    "git+https://github.com/Panduza/panduza-py.git@0.1.0#egg=panduza_platform&subdirectory=platform/" \
    "git+https://github.com/Panduza/panduza-admin-dashboard@0.1.1" \
    )

# ===================================================================

# 
function install_systemctl_sudo_permissions() {
    echo "%LimitedAdmins ALL=NOPASSWD: /bin/systemctl start panduza-py-platform.service" > /etc/sudoers.d/panduza
}

#
service_panduza_admin_path=/etc/systemd/system/panduza-admin.service
function install_systemctl_admin_service() {

    path_to_admin_main=`readlink -e ${PYTHON_VENV_PATH}/lib/python3*/site-packages/panduza_admin_dashboard/__main__.py`
    echo "---> ${path_to_admin_main}"

    echo "[Unit]" > ${service_panduza_admin_path}
    echo "Description=Panduza Admin Dashboard" >> ${service_panduza_admin_path}
    echo "After=network.target" >> ${service_panduza_admin_path}
    echo "[Service]" >> ${service_panduza_admin_path}
    echo "User=root" >> ${service_panduza_admin_path}
    echo "ExecStart=${PYTHON_VENV_PATH}/bin/python3 ${path_to_admin_main}" >> ${service_panduza_admin_path}
    echo "ExecStop=/bin/kill $MAINPID" >> ${service_panduza_admin_path}
    echo "[Install]" >> ${service_panduza_admin_path}
    echo "WantedBy=multi-user.target" >> ${service_panduza_admin_path}
}

#
service_panduza_platform_path=/etc/systemd/system/panduza-py-platform.service
function install_systemctl_platform_service() {

    path_to_platform_main=`readlink -e ${PYTHON_VENV_PATH}/lib/python3*/site-packages/panduza_platform/__main__.py`
    echo "---> ${path_to_platform_main}"

    echo "[Unit]" > ${service_panduza_platform_path}
    echo "Description=Platform Python to support Panduza Meta Drivers" >> ${service_panduza_platform_path}
    echo "After=network.target" >> ${service_panduza_platform_path}
    echo "[Service]" >> ${service_panduza_platform_path}
    echo "User=root" >> ${service_panduza_platform_path}
    echo "ExecStart=${PYTHON_VENV_PATH}/bin/python3 ${path_to_platform_main}" >> ${service_panduza_platform_path}
    
    echo "[Install]" >> ${service_panduza_platform_path}
    echo "WantedBy=multi-user.target" >> ${service_panduza_platform_path}
}

#
function generic_install() {
    rm -rf ${PYTHON_VENV_PATH}

    python3 -m venv ${PYTHON_VENV_PATH}

    mkdir -p /etc/panduza/

    # Install all modules
    for i in "${PYTHON_MODULES[@]}"
    do
        echo ""
        echo "==================================="
        echo "==================================="
        echo "= INSTALL > $i <"
        echo ""
        ${PYTHON_VENV_PATH}/bin/pip3 install $i
    done


    


    install_systemctl_admin_service
    install_systemctl_platform_service
    install_systemctl_sudo_permissions
    systemctl daemon-reload
    systemctl enable panduza-admin.service
}




# --------------------------
# Get system
# --------------------------

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
# Ubuntu_22.04
# --------------------------

if [[ $osv == "Ubuntu_22.04" ]]; then
    apt-get install -y git python3 python3-pip python3-venv mosquitto
    generic_install

    wget ${ASSETS_URL}/85-brltty.rules
    mv -f 85-brltty.rules /usr/lib/udev/rules.d/85-brltty.rules

    wget ${ASSETS_URL}/mosquitto/mosquitto.conf
    mv -f mosquitto.conf /etc/mosquitto/mosquitto.conf

    exit 0
fi

# --------------------------
# ManjaroLinux_23.0.0
# --------------------------

if [[ $osv == "ManjaroLinux_23.0.0" ]]; then
    pacman -S python --noconfirm
    pacman -S python-pip --noconfirm
    pacman -S mosquitto --noconfirm
    generic_install
    exit 0
fi

# --------------------------
# END
# --------------------------

echo "OS NOT SUPPORTED"

