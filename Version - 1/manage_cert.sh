#!/bin/bash

# --------------------------------------------------------
# Script: manage_cert.sh
# Purpose: Manage Cloudflare cert.pem files in /home/<sys-username>/.cloudflared/
# Written by: Shubham Vishwakarma
# Connect with him: https://instagram.com/itsbhm.me
# --------------------------------------------------------

# Set the working directory to /home/onespider/.cloudflared/
WORK_DIR="/home/onespider/.cloudflared"
AUTH_DIR="${WORK_DIR}/auth"

# Ensure the /auth folder exists
if [ ! -d "$AUTH_DIR" ]; then
    echo "Creating /auth directory in $WORK_DIR..."
    mkdir -p "$AUTH_DIR"
fi

# Function to move and rename cert.pem file
move_and_rename_cert() {
    SOURCE_PATH="${WORK_DIR}/cert.pem"

    if [ ! -f "$SOURCE_PATH" ]; then
        echo "Error: cert.pem file not found in $WORK_DIR."
        return
    fi

    read -p "Enter the name for the cert file (without extension): " CERT_NAME
    TARGET_PATH="${AUTH_DIR}/${CERT_NAME}.cert.pem"
    
    # Move and rename the file
    mv "$SOURCE_PATH" "$TARGET_PATH"
    if [ $? -eq 0 ]; then
        echo "File successfully moved to: $TARGET_PATH"
    else
        echo "Error moving the file."
    fi
}

# Function to set TUNNEL_ORIGIN_CERT environment variable permanently
set_tunnel_origin_cert() {
    echo "Available cert files in $AUTH_DIR:"
    ls "$AUTH_DIR"/*.cert.pem 2>/dev/null || { echo "No cert files found."; return; }
    
    read -p "Enter the cert file name to set as TUNNEL_ORIGIN_CERT (without path): " CERT_FILE
    if [ -f "${AUTH_DIR}/${CERT_FILE}" ]; then
        # Append the export command to ~/.bashrc (for permanent use in your user sessions)
        echo "export TUNNEL_ORIGIN_CERT=${AUTH_DIR}/${CERT_FILE}" >> ~/.bashrc
        echo "TUNNEL_ORIGIN_CERT set to: ${AUTH_DIR}/${CERT_FILE}. This will take effect permanently for all future terminal sessions."
        
        # Reload ~/.bashrc to apply the change immediately
        source ~/.bashrc
        echo "The environment variable is now set and loaded into the current session."
    else
        echo "Error: Cert file not found in $AUTH_DIR."
    fi
}

# Function to get the full path of a cert file
get_cert_path() {
    echo "Available cert files in $AUTH_DIR:"
    ls "$AUTH_DIR"/*.cert.pem 2>/dev/null || { echo "No cert files found."; return; }
    
    read -p "Enter the cert file name to get the full path (without path): " CERT_FILE
    if [ -f "${AUTH_DIR}/${CERT_FILE}" ]; then
        echo "Full path of the cert file: ${AUTH_DIR}/${CERT_FILE}"
    else
        echo "Error: Cert file not found in $AUTH_DIR."
    fi
}

# Function to check the current value of TUNNEL_ORIGIN_CERT
check_tunnel_origin_cert() {
    if [ -z "$TUNNEL_ORIGIN_CERT" ]; then
        echo "TUNNEL_ORIGIN_CERT is not set."
    else
        echo "Current TUNNEL_ORIGIN_CERT: $TUNNEL_ORIGIN_CERT"
    fi
}

# Menu for script options
while true; do
    echo
    echo "Choose an option:"
    echo "1) Move and rename cert.pem"
    echo "2) Set TUNNEL_ORIGIN_CERT environment variable"
    echo "3) Get the full path of a cert file"
    echo "4) Check TUNNEL_ORIGIN_CERT value"
    echo "5) Exit"
    read -p "Enter your choice: " CHOICE

    case $CHOICE in
        1) move_and_rename_cert ;;
        2) set_tunnel_origin_cert ;;
        3) get_cert_path ;;
        4) check_tunnel_origin_cert ;;
        5) echo "Exiting... | Written by: Shubham Vishwakarma | Connect with him: instagram.com/itsbhm.me"; exit 0 ;;
        *) echo "Invalid choice. Please try again." ;;
    esac
done
