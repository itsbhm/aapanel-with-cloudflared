#!/bin/bash

# --------------------------------------------------------
# Script: install_aaPanel.sh
# Purpose: A script for installing aaPanel and checking system resources.
# Written by: Shubham Vishwakarma
# Connect with him: https://instagram.com/itsbhm.me
# --------------------------------------------------------

# Function to check available system information
check_system_info() {
    echo "🔍 Checking system information..."
    echo "🖥️ Total available CPU cores:"
    nproc
    echo ""
    
    echo "💾 Checking storage usage:"
    df -h
    echo ""
    
    echo "⚙️ Checking processor details:"
    lscpu
    echo ""
    
    echo "🌐 Checking active ports:"
    sudo netstat -tuln
    echo ""
    
    echo "🌍 Checking system's local IP address:"
    ip a | grep inet | grep -v inet6
    echo ""
}

# Main menu
while true; do
    echo "🔧 Please select an option:"
    echo "1) 🆙 Update existing dependencies and tools"
    echo "2) 📦 Install wget, git, unzip, software-properties-common, ufw"
    echo "3) 📥 Download aaPanel"
    echo "4) ⚙️ Install aaPanel"
    echo "5) 🚀 Download and Install aaPanel (Combined)"
    echo "6) 🔥 Do everything silently"
    echo "7) 🖥️ Check system information (CPU, Storage, Processor, Ports, IP)"
    echo "8) 🚪 Exit"
    read -p "Enter your choice (1-8): " option

    case $option in
        1)
            echo "🔄 Updating existing dependencies and tools..."
            sudo apt update && sudo apt upgrade -y
            ;;
        2)
            echo "📦 Installing wget, git, unzip, software-properties-common, ufw..."
            sudo apt install -y curl wget git unzip software-properties-common ufw
            ;;
        3)
            echo "⬇️ Downloading aaPanel..."
            wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
            ;;
        4)
            echo "⚙️ Installing aaPanel..."
            bash install.sh
            ;;
        5)
            echo "🚀 Downloading and installing aaPanel (combined)..."
            wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
            bash install.sh
            ;;
        6)
            echo "🔥 Doing everything silently..."
            sudo apt update && sudo apt upgrade -y
            sudo apt install -y curl wget git unzip software-properties-common ufw
            wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh
            bash install.sh
            ;;
        7)
            check_system_info
            ;;
        8)
            echo "👋 Exiting script. Goodbye!"
            exit 0
            ;;
        *)
            echo "❌ Invalid option! Please select a number between 1 and 8."
            ;;
    esac
done