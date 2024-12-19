#!/bin/bash

# --- 1. Install / Uninstall cloudflared ---
install_cloudflared() {
    echo "Installing cloudflared..."
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
    sudo dpkg -i cloudflared.deb
    sudo apt-get install -f
    rm cloudflared.deb
    echo "cloudflared installation complete."
}

uninstall_cloudflared() {
    echo "Uninstalling cloudflared..."
    sudo apt-get remove --purge cloudflared -y
    sudo apt-get autoremove -y
    echo "cloudflared uninstallation complete."
}

# --- 2. Create new tunnel ---
create_tunnel() {
    read -p "Enter tunnel name: " tunnel_name
    cloudflared tunnel create "$tunnel_name"
    echo "Tunnel '$tunnel_name' created successfully."
}

# --- 3. Configure Tunnel with YAML File ---
configure_tunnel() {
    read -p "Enter tunnel name: " tunnel_name
    read -p "Enter domain: " domain
    read -p "Enter local service (e.g., http://localhost:8686): " service_url
    read -p "Enter credentials filename (without .json): " credentials_filename

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
    echo "Credentials file set as $credentials_file."
}

# --- 4. Delete Tunnel ---
delete_tunnel() {
    read -p "Enter tunnel name to delete: " tunnel_name
    cloudflared tunnel delete "$tunnel_name"
    echo "Tunnel '$tunnel_name' deleted."
}

# --- 5. Cloudflare login ---
cloudflare_login() {
    cloudflared login
    echo "Cloudflare login successful."
}

# --- 6. Run the Tunnels Manually (For Testing) ---
run_tunnel_manually() {
    read -p "Enter tunnel name: " tunnel_name
    read -p "Enter username for tunnel files (e.g., $(whoami)): " username
    sudo cloudflared tunnel --config /home/$username/.cloudflared/${tunnel_name}.yml run
}

# --- 7. Create a Systemd Service ---
create_systemd_service() {
    read -p "Enter tunnel name: " tunnel_name
    read -p "Enter username for tunnel files (e.g., $(whoami)): " username
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


# --- 8. Enable and Start the Service ---
enable_and_start_service() {
    read -p "Enter tunnel name: " tunnel_name
    sudo systemctl daemon-reload
    sudo systemctl enable cloudflared-$tunnel_name.service
    sudo systemctl start cloudflared-$tunnel_name.service
    echo "Service 'cloudflared-$tunnel_name' is now active and enabled to start on boot."
}

# --- 9. Disabling a Service ---
disable_service() {
    read -p "Enter tunnel name: " tunnel_name
    sudo systemctl disable cloudflared-$tunnel_name
    echo "Service for tunnel '$tunnel_name' disabled."
}

# --- 10. Restarting a Service ---
restart_service() {
    read -p "Enter tunnel name: " tunnel_name
    sudo systemctl restart cloudflared-$tunnel_name
    echo "Service for tunnel '$tunnel_name' restarted."
}

# --- 11. Stopping and Deleting a Service (Stop the Service) ---
stop_service() {
    read -p "Enter tunnel name: " tunnel_name
    sudo systemctl stop cloudflared-$tunnel_name
    echo "Service for tunnel '$tunnel_name' stopped."
}

# --- 12. Stopping and Deleting a Service (Disable the Service) ---
disable_service_file() {
    read -p "Enter tunnel name: " tunnel_name
    sudo systemctl disable cloudflared-$tunnel_name
    echo "Service for tunnel '$tunnel_name' disabled."
}

# --- 13. Stopping and Deleting a Service (Delete the Service File) ---
delete_service_file() {
    read -p "Enter tunnel name: " tunnel_name
    sudo rm /etc/systemd/system/cloudflared-$tunnel_name.service
    sudo systemctl daemon-reload
    echo "Service file for tunnel '$tunnel_name' deleted."
}

# --- 14. Stopping and Deleting a Service (Reload systemd) ---
reload_systemd() {
    sudo systemctl daemon-reload
    echo "Systemd reloaded."
}

# --- 15. Verify Tunnel Status ---
verify_tunnel_status() {
    cloudflared tunnel list
}

# --- 16. Check system status ---
check_system_status() {
    echo "System Status:"
    echo "CPU Core(s): $(nproc)"
    echo "RAM: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
    echo "Disk: $(df -h / | grep / | awk '{print $3 "/" $2}')"
    echo "Local IP: $(hostname -I | awk '{print $1}')"
}

# --- Main Menu ---
echo "Select an action:"
echo "1) Install cloudflared"
echo "2) Uninstall cloudflared"
echo "3) Create new tunnel"
echo "4) Configure Tunnel with YAML file"
echo "5) Delete Tunnel"
echo "6) Cloudflare login"
echo "7) Run tunnel manually"
echo "8) Create systemd service"
echo "9) Enable and start the service"
echo "10) Disable the service"
echo "11) Restart the service"
echo "12) Stop the service"
echo "13) Delete service file"
echo "14) Reload systemd"
echo "15) Verify tunnel status"
echo "16) Check system status"
read -p "Enter your choice (1-16): " choice

case $choice in
    1) install_cloudflared ;;
    2) uninstall_cloudflared ;;
    3) create_tunnel ;;
    4) configure_tunnel ;;
    5) delete_tunnel ;;
    6) cloudflare_login ;;
    7) run_tunnel_manually ;;
    8) create_systemd_service ;;
    9) enable_and_start_service ;;
    10) disable_service ;;
    11) restart_service ;;
    12) stop_service ;;
    13) delete_service_file ;;
    14) reload_systemd ;;
    15) verify_tunnel_status ;;
    16) check_system_status ;;
    *) echo "Invalid option!" ;;
esac
