#!/bin/bash

# Function to enable UFW
enable_ufw() {
    echo "Enabling UFW..."
    sudo ufw enable
    echo "UFW is now enabled."
}

# Function to disable UFW
disable_ufw() {
    echo "Disabling UFW..."
    sudo ufw disable
    echo "UFW is now disabled."
}

# Function to allow a specific port
allow_port() {
    PORT=$1
    if [ -z "$PORT" ]; then
        echo "Error: No port number provided!"
        return
    fi

    echo "Allowing traffic on port $PORT..."
    sudo ufw allow $PORT
    echo "Port $PORT is now allowed."
}

# Function to deny a specific port
deny_port() {
    PORT=$1
    if [ -z "$PORT" ]; then
        echo "Error: No port number provided!"
        return
    fi

    echo "Denying traffic on port $PORT..."
    sudo ufw deny $PORT
    echo "Port $PORT is now denied."
}

# Function to show the UFW status
status_ufw() {
    echo "Checking UFW status..."
    sudo ufw status verbose
}

# Function to list all allowed ports with details
list_allowed_ports() {
    echo "Listing all allowed ports with details..."
    
    # Get the status with details and filter out only the lines that have "ALLOW"
    sudo ufw status verbose | grep -i "ALLOW" | while read line; do
        # Extract the port, protocol, and IP version (IPv4 or IPv6)
        # Example format: 80/tcp                     ALLOW       Anywhere
        #                443/tcp (v6)                ALLOW       Anywhere (v6)
        
        # Extract protocol and port, along with IP version (v4 or v6)
        port_and_protocol=$(echo $line | awk '{print $1}')
        ip_version=$(echo $line | grep -o "(v[46])")
        action=$(echo $line | awk '{print $2}')
        description=$(echo $line | awk '{print $3, $4}')
        
        # If there is an IPv6 address, it will show (v6), otherwise it will be blank
        echo "Port: $port_and_protocol  Action: $action  IP Version: $ip_version  Description: $description"
    done
}

# Function to reset UFW (removes all rules)
reset_ufw() {
    echo "Resetting UFW to default settings..."
    sudo ufw reset
    echo "UFW has been reset. All rules have been cleared."
}

# Function to enable UFW with default rules for HTTP/HTTPS/SSH
enable_with_rules() {
    echo "Enabling UFW with default rules..."
    
    # Allow standard ports for HTTP and HTTPS
    sudo ufw allow 80    # HTTP
    sudo ufw allow 443   # HTTPS
    sudo ufw allow 22    # SSH (ensure you don't lock yourself out)

    # Enable UFW after adding rules
    sudo ufw enable
    echo "UFW is enabled with rules for HTTP, HTTPS, and SSH."
}

# Main menu to interact with the script
menu() {
    echo "------------------------ UFW Management ------------------------"
    echo "1. Enable UFW"
    echo "2. Disable UFW"
    echo "3. Allow a Port"
    echo "4. Deny a Port"
    echo "5. Check UFW Status"
    echo "6. Reset UFW"
    echo "7. Enable UFW with Default Rules (HTTP, HTTPS, SSH)"
    echo "8. List Allowed Ports with Details"
    echo "9. Exit"
    echo "---------------------------------------------------------------"
    read -p "Please select an option (1-9): " option
    
    case $option in
        1)
            enable_ufw
            ;;
        2)
            disable_ufw
            ;;
        3)
            read -p "Enter the port number to allow (e.g., 80 for HTTP, 443 for HTTPS): " port
            allow_port $port
            ;;
        4)
            read -p "Enter the port number to deny (e.g., 80 for HTTP, 443 for HTTPS): " port
            deny_port $port
            ;;
        5)
            status_ufw
            ;;
        6)
            reset_ufw
            ;;
        7)
            enable_with_rules
            ;;
        8)
            list_allowed_ports
            ;;
        9)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            menu
            ;;
    esac
}

# Start the menu
menu