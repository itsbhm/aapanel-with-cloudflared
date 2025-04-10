#!/bin/bash

# Script to install and configure SSH, Node.js, and set timezone
# Author: Shubham Vishwakarma
# GitHub: https://github.com/itsbhm
# Instagram: https://www.instagram.com/itsbhm.me
# Web: https://itsbhm.com/

# Function to install OpenSSH server and enable SSH
install_ssh() {
    if dpkg -l | grep -q openssh-server; then
        echo "OpenSSH server is already installed. Skipping installation."
    else
        echo "Installing OpenSSH server..."
        sudo apt update
        sudo apt install -y openssh-server
        sudo ufw allow ssh
        sudo systemctl status ssh
        sudo systemctl start ssh
        echo "SSH setup complete!"
    fi
}

# Function to install Node.js (v22.x)
install_node() {
    NODE_VERSION="22.x"
    echo "You are installing Node.js version $NODE_VERSION."
    curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "Installed Node.js version: $(node -v)"
    echo "Node.js installation complete!"
}

# Function to install updates
install_updates() {
    echo "Updating system..."
    sudo apt update && sudo apt upgrade -y
    echo "System updated!"
}

# Function to set the timezone
set_timezone() {
    echo "Listing available timezones for Asia..."
    timedatectl list-timezones | grep Asia
    echo "Setting timezone to Asia/Kolkata..."
    sudo timedatectl set-timezone Asia/Kolkata
    echo "Timezone set to Asia/Kolkata!"
}

# Show menu and let user select options
show_menu() {
    echo "Select an option:"
    echo "1) Install and configure SSH"
    echo "2) Install Node.js"
    echo "3) Install system updates"
    echo "4) Set timezone to Asia/Kolkata"
    echo "5) Exit"
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice [1-5]: " choice
    case $choice in
        1) install_ssh ;;
        2) install_node ;;
        3) install_updates ;;
        4) set_timezone ;;
        5) echo "Exiting script."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
