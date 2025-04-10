#!/bin/bash
# ------------------------------------------------------------------------------
# Comprehensive Server Management Script
#
# This script integrates the following functionalities:
#   1. Cloudflared Management – install/uninstall, tunnel creation and configuration,
#      DNS routing, Cloudflare login, and systemd service management.
#   2. aaPanel Installation & System Resource Check – update dependencies,
#      install required packages, and install aaPanel.
#   3. Cloudflare Auth Certificate Management – move and rename cert.pem, set and 
#      check TUNNEL_ORIGIN_CERT.
#   4. UFW Firewall Management – enable/disable UFW, allow/deny ports, list rules, 
#      and reset UFW.
#   5. Server Preparation – SSH installation and configuration, Node.js setup,
#      system updates, and timezone configuration.
#
# Written by: Shubham Vishwakarma
# Connect: GitHub: https://github.com/itsbhm | Instagram: https://instagram.com/itsbhm.me
# Web: https://itsbhm.com/
# ------------------------------------------------------------------------------

###############################
#       CLOUDFLARED SECTION   #
###############################

install_cloudflared() {
    echo "Installing Cloudflared..."
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
    sudo dpkg -i cloudflared.deb
    sudo apt-get install -f -y
    rm cloudflared.deb
    echo "Cloudflared installation complete."
}

uninstall_cloudflared() {
    echo "Uninstalling Cloudflared..."
    sudo apt-get remove --purge cloudflared -y
    sudo apt-get autoremove -y
    echo "Cloudflared uninstallation complete."
}

create_tunnel() {
    read -p "Enter the tunnel name: " tunnel_name
    cloudflared tunnel create "$tunnel_name"
    echo "Tunnel '$tunnel_name' created successfully."
}

configure_tunnel() {
    read -p "Enter the tunnel name: " tunnel_name
    read -p "Enter the domain name: " domain
    read -p "Enter the local service URL (e.g., http://localhost:8686): " service_url
    read -p "Enter the credentials filename (without .json extension): " credentials_filename

    config_file="/home/$USER/.cloudflared/${tunnel_name}.yml"
    credentials_file="/home/$USER/.cloudflared/auth/${credentials_filename}.json"

    sudo bash -c "cat > $config_file" <<EOF
tunnel: $tunnel_name
credentials-file: $credentials_file

ingress:
  - hostname: $domain
    service: $service_url
  - service: http_status:404
EOF

    echo "Configuration file for tunnel '$tunnel_name' created at $config_file."
    echo "Credentials file located at $credentials_file."
}

route_dns_to_tunnel() {
    read -p "Enter the tunnel name: " tunnel_name
    read -p "Enter the domain name to route (e.g., sub.example.com): " domain
    cloudflared tunnel route dns "$tunnel_name" "$domain"
    echo "DNS route for '$domain' to tunnel '$tunnel_name' has been set."
}

delete_tunnel() {
    read -p "Enter the tunnel name to delete: " tunnel_name
    cloudflared tunnel delete "$tunnel_name"
    echo "Tunnel '$tunnel_name' deleted."
}

cloudflare_login() {
    cloudflared login
    echo "Cloudflare login successful."
}

run_tunnel_manually() {
    read -p "Enter the tunnel name: " tunnel_name
    read -p "Enter your username for tunnel files (e.g., $(whoami)): " username
    sudo cloudflared tunnel --config /home/$username/.cloudflared/${tunnel_name}.yml run
}

create_systemd_service() {
    read -p "Enter the tunnel name: " tunnel_name
    read -p "Enter your username for tunnel files (e.g., $(whoami)): " username
    service_file="/etc/systemd/system/cloudflared-$tunnel_name.service"

    sudo bash -c "cat > $service_file" <<EOF
[Unit]
Description=Cloudflare Tunnel for $tunnel_name
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel --config /home/$username/.cloudflared/$tunnel_name.yml run
Restart=on-failure
User=$username

[Install]
WantedBy=multi-user.target
EOF

    echo "Systemd service for tunnel '$tunnel_name' created at $service_file."
}

enable_and_start_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl daemon-reload
    sudo systemctl enable cloudflared-$tunnel_name.service
    sudo systemctl start cloudflared-$tunnel_name.service
    echo "Service 'cloudflared-$tunnel_name' is active and enabled on boot."
}

disable_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl disable cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' disabled."
}

restart_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl restart cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' restarted."
}

stop_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl stop cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' stopped."
}

delete_service_file() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo rm /etc/systemd/system/cloudflared-$tunnel_name.service
    sudo systemctl daemon-reload
    echo "Service file for tunnel '$tunnel_name' deleted."
}

reload_systemd() {
    sudo systemctl daemon-reload
    echo "Systemd reloaded."
}

verify_tunnel_status() {
    cloudflared tunnel list
}

check_system_status() {
    echo "System Status:"
    echo "CPU Core(s): $(nproc)"
    echo "RAM Usage: $(free -h | awk '/^Mem/ {print $3 "/" $2}')"
    echo "Disk Usage: $(df -h / | awk '/\// {print $3 "/" $2}')"
    echo "Local IP Address: $(hostname -I | awk '{print $1}')"
}

check_environment_processes() {
    echo "Cloudflared Environment Variables:"
    printenv | grep TUNNEL

    echo -e "\nCloudflared Processes:"
    ps aux | grep cloudflared

    echo -e "\nSystemd Services for Cloudflared:"
    systemctl list-units --type=service | grep cloudflared
}

cloudflared_menu() {
    clear
    echo "-----------------------------"
    echo "     Cloudflared Management"
    echo "-----------------------------"
    echo "1) Install Cloudflared"
    echo "2) Uninstall Cloudflared"
    echo "3) Create a New Tunnel"
    echo "4) Configure a Tunnel (YAML)"
    echo "5) Route DNS to a Tunnel"
    echo "6) Delete a Tunnel"
    echo "7) Cloudflare Login"
    echo "8) Run a Tunnel Manually"
    echo "9) Create a systemd Service"
    echo "10) Enable and Start Service"
    echo "11) Disable Service"
    echo "12) Restart Service"
    echo "13) Stop Service"
    echo "14) Delete Service File"
    echo "15) Reload systemd"
    echo "16) Verify Tunnel Status"
    echo "17) Check System Status"
    echo "18) Check Environment and Processes"
    echo "19) Return to Main Menu"
    echo "-----------------------------"
    read -p "Enter your choice (1-19): " choice_cloud

    case $choice_cloud in
        1) install_cloudflared ;;
        2) uninstall_cloudflared ;;
        3) create_tunnel ;;
        4) configure_tunnel ;;
        5) route_dns_to_tunnel ;;
        6) delete_tunnel ;;
        7) cloudflare_login ;;
        8) run_tunnel_manually ;;
        9) create_systemd_service ;;
        10) enable_and_start_service ;;
        11) disable_service ;;
        12) restart_service ;;
        13) stop_service ;;
        14) delete_service_file ;;
        15) reload_systemd ;;
        16) verify_tunnel_status ;;
        17) check_system_status ;;
        18) check_environment_processes ;;
        19) return ;;
        *) echo "Invalid option!";;
    esac
    echo "Press enter to continue..."
    read
}

###############################
#    AAPANEL & SYSTEM INFO    #
###############################

update_dependencies() {
    echo "Updating existing dependencies and tools..."
    sudo apt update && sudo apt upgrade -y
}

install_basic_tools() {
    echo "Installing essential packages (curl, wget, git, unzip, software-properties-common, ufw)..."
    sudo apt install -y curl wget git unzip software-properties-common ufw
}

download_aapanel() {
    echo "Downloading aaPanel..."
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
}

install_aapanel() {
    echo "Installing aaPanel..."
    bash install.sh
}

install_aapanel_combined() {
    echo "Downloading and installing aaPanel..."
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
    bash install.sh
}

system_info() {
    echo "🔍 Checking system information..."
    echo "🖥️ Total available CPU cores:"; nproc
    echo ""
    echo "💾 Storage usage:"; df -h
    echo ""
    echo "⚙️ Processor details:"; lscpu
    echo ""
    echo "🌐 Active ports:"; sudo netstat -tuln
    echo ""
    echo "🌍 Local IP address:"; ip a | grep inet | grep -v inet6
}

aapanel_menu() {
    clear
    echo "---------------------------------------"
    echo "   aaPanel Installation & System Info"
    echo "---------------------------------------"
    echo "1) Update Dependencies and Tools"
    echo "2) Install Essential Packages"
    echo "3) Download aaPanel"
    echo "4) Install aaPanel"
    echo "5) Combined: Download and Install aaPanel"
    echo "6) Display System Information"
    echo "7) Return to Main Menu"
    echo "---------------------------------------"
    read -p "Enter your choice (1-7): " choice_aapanel

    case $choice_aapanel in
        1) update_dependencies ;;
        2) install_basic_tools ;;
        3) download_aapanel ;;
        4) install_aapanel ;;
        5) install_aapanel_combined ;;
        6) system_info ;;
        7) return ;;
        *) echo "Invalid option!";;
    esac
    echo "Press enter to continue..."
    read
}

#########################################
#  CLOUDFLARE AUTH CERTIFICATE SECTION  #
#########################################

move_and_rename_cert() {
    WORK_DIR="/home/$(whoami)/.cloudflared"
    AUTH_DIR="${WORK_DIR}/auth"
    SOURCE_PATH="${WORK_DIR}/cert.pem"
    if [ ! -f "$SOURCE_PATH" ]; then
        echo "Error: cert.pem file not found in $WORK_DIR."
        return
    fi
    read -p "Enter the new name for the cert file (without extension): " CERT_NAME
    TARGET_PATH="${AUTH_DIR}/${CERT_NAME}.cert.pem"
    mv "$SOURCE_PATH" "$TARGET_PATH"
    if [ $? -eq 0 ]; then
        echo "File successfully moved to: $TARGET_PATH"
    else
        echo "Error moving the file."
    fi
}

set_tunnel_origin_cert() {
    WORK_DIR="/home/$(whoami)/.cloudflared"
    AUTH_DIR="${WORK_DIR}/auth"
    echo "Available cert files in $AUTH_DIR:"
    ls "$AUTH_DIR"/*.cert.pem 2>/dev/null || { echo "No cert files found."; return; }
    read -p "Enter the cert file name to set as TUNNEL_ORIGIN_CERT (with extension): " CERT_FILE
    if [ -f "${AUTH_DIR}/${CERT_FILE}" ]; then
        echo "export TUNNEL_ORIGIN_CERT=${AUTH_DIR}/${CERT_FILE}" >> ~/.bashrc
        echo "TUNNEL_ORIGIN_CERT set to: ${AUTH_DIR}/${CERT_FILE}"
        source ~/.bashrc
        echo "The environment variable is now set and loaded."
    else
        echo "Error: Cert file not found in $AUTH_DIR."
    fi
}

get_cert_path() {
    WORK_DIR="/home/$(whoami)/.cloudflared"
    AUTH_DIR="${WORK_DIR}/auth"
    echo "Available cert files in $AUTH_DIR:"
    ls "$AUTH_DIR"/*.cert.pem 2>/dev/null || { echo "No cert files found."; return; }
    read -p "Enter the cert file name to get the full path (with extension): " CERT_FILE
    if [ -f "${AUTH_DIR}/${CERT_FILE}" ]; then
        echo "Full path: ${AUTH_DIR}/${CERT_FILE}"
    else
        echo "Error: Cert file not found in $AUTH_DIR."
    fi
}

check_tunnel_origin_cert() {
    if [ -z "$TUNNEL_ORIGIN_CERT" ]; then
        echo "TUNNEL_ORIGIN_CERT is not set."
    else
        echo "Current TUNNEL_ORIGIN_CERT: $TUNNEL_ORIGIN_CERT"
    fi
}

auth_cert_menu() {
    clear
    echo "---------------------------------------------"
    echo "     Cloudflare Auth Certificate Management"
    echo "---------------------------------------------"
    echo "1) Move and Rename cert.pem"
    echo "2) Set TUNNEL_ORIGIN_CERT Environment Variable"
    echo "3) Get Full Path of a Cert File"
    echo "4) Check TUNNEL_ORIGIN_CERT Value"
    echo "5) Return to Main Menu"
    echo "---------------------------------------------"
    read -p "Enter your choice (1-5): " choice_auth

    case $choice_auth in
        1) move_and_rename_cert ;;
        2) set_tunnel_origin_cert ;;
        3) get_cert_path ;;
        4) check_tunnel_origin_cert ;;
        5) return ;;
        *) echo "Invalid option!";;
    esac
    echo "Press enter to continue..."
    read
}

#########################
#      UFW SECTION      #
#########################

enable_ufw() {
    echo "Enabling UFW..."
    sudo ufw enable
    echo "UFW is now enabled."
}

disable_ufw() {
    echo "Disabling UFW..."
    sudo ufw disable
    echo "UFW is now disabled."
}

allow_port() {
    read -p "Enter the port number to allow: " PORT
    if [ -z "$PORT" ]; then
        echo "Error: No port number provided!"
        return
    fi
    echo "Allowing traffic on port $PORT..."
    sudo ufw allow $PORT
    echo "Port $PORT is now allowed."
}

deny_port() {
    read -p "Enter the port number to deny: " PORT
    if [ -z "$PORT" ]; then
        echo "Error: No port number provided!"
        return
    fi
    echo "Denying traffic on port $PORT..."
    sudo ufw deny $PORT
    echo "Port $PORT is now denied."
}

status_ufw() {
    echo "Checking UFW status..."
    sudo ufw status verbose
}

list_allowed_ports() {
    echo "Listing all allowed ports with details..."
    sudo ufw status verbose | grep -i "ALLOW" | while read line; do
        port_and_protocol=$(echo $line | awk '{print $1}')
        ip_version=$(echo $line | grep -o "(v[46])")
        action=$(echo $line | awk '{print $2}')
        description=$(echo $line | awk '{print $3, $4}')
        echo "Port: $port_and_protocol  Action: $action  IP Version: $ip_version  Description: $description"
    done
}

reset_ufw() {
    echo "Resetting UFW to default settings..."
    sudo ufw reset
    echo "UFW has been reset. All rules have been cleared."
}

enable_with_default_rules() {
    echo "Enabling UFW with default rules for HTTP, HTTPS, and SSH..."
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw allow 22
    sudo ufw enable
    echo "UFW is enabled with default rules."
}

ufw_menu() {
    clear
    echo "---------------------------------"
    echo "         UFW Firewall Menu"
    echo "---------------------------------"
    echo "1) Enable UFW"
    echo "2) Disable UFW"
    echo "3) Allow a Port"
    echo "4) Deny a Port"
    echo "5) Check UFW Status"
    echo "6) Reset UFW"
    echo "7) Enable UFW with Default Rules (HTTP, HTTPS, SSH)"
    echo "8) List Allowed Ports"
    echo "9) Return to Main Menu"
    echo "---------------------------------"
    read -p "Enter your choice (1-9): " choice_ufw

    case $choice_ufw in
        1) enable_ufw ;;
        2) disable_ufw ;;
        3) allow_port ;;
        4) deny_port ;;
        5) status_ufw ;;
        6) reset_ufw ;;
        7) enable_with_default_rules ;;
        8) list_allowed_ports ;;
        9) return ;;
        *) echo "Invalid option!";;
    esac
    echo "Press enter to continue..."
    read
}

#########################
#   SERVER PREPARATION  #
#########################

install_ssh() {
    if dpkg -l | grep -q openssh-server; then
        echo "OpenSSH server is already installed. Skipping installation."
    else
        echo "Installing OpenSSH server..."
        sudo apt update
        sudo apt install -y openssh-server
        sudo ufw allow ssh
        sudo systemctl start ssh
        echo "SSH setup complete!"
    fi
}

install_node() {
    NODE_VERSION="22.x"
    echo "Installing Node.js version $NODE_VERSION..."
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "Installed Node.js version: $(node -v)"
    echo "Node.js installation complete!"
}

install_updates() {
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y
    echo "System updated!"
}

set_timezone() {
    echo "Listing available timezones for Asia..."
    timedatectl list-timezones | grep Asia
    echo "Setting timezone to Asia/Kolkata..."
    sudo timedatectl set-timezone Asia/Kolkata
    echo "Timezone set to Asia/Kolkata!"
}

server_prep_menu() {
    clear
    echo "-------------------------------"
    echo "       Server Preparation"
    echo "-------------------------------"
    echo "1) Install and Configure SSH"
    echo "2) Install Node.js (v22.x)"
    echo "3) Update System"
    echo "4) Set Timezone to Asia/Kolkata"
    echo "5) Return to Main Menu"
    echo "-------------------------------"
    read -p "Enter your choice (1-5): " choice_prep

    case $choice_prep in
        1) install_ssh ;;
        2) install_node ;;
        3) install_updates ;;
        4) set_timezone ;;
        5) return ;;
        *) echo "Invalid option!";;
    esac
    echo "Press enter to continue..."
    read
}

#########################
#        MAIN MENU      #
#########################

while true; do
    clear
    echo "====================================================="
    echo " Comprehensive Server Management Script"
    echo " Written by: Shubham Vishwakarma"
    echo " Connect: GitHub: https://github.com/itsbhm | Instagram: https://instagram.com/itsbhm.me"
    echo " Web: https://itsbhm.com/"
    echo "====================================================="
    echo "Select a Category:"
    echo "1) Cloudflared Management"
    echo "2) aaPanel Installation & System Info"
    echo "3) Cloudflare Auth Certificate Management"
    echo "4) UFW Firewall Management"
    echo "5) Server Preparation (SSH, Node.js, Updates, Timezone)"
    echo "6) Exit"
    echo "====================================================="
    read -p "Enter your choice (1-6): " main_choice

    case $main_choice in
        1) cloudflared_menu ;;
        2) aapanel_menu ;;
        3) auth_cert_menu ;;
        4) ufw_menu ;;
        5) server_prep_menu ;;
        6) echo "Exiting script. Goodbye!"; exit 0 ;;
        *) echo "Invalid option! Please choose between 1 and 6."; read -p "Press enter to continue..." ;;
    esac
done
