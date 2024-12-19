#!/bin/bash

# --------------------------------------------------------
# Comprehensive Cloudflared Management Script
# Written by: Shubham Vishwakarma
# Connect with me: https://instagram.com/itsbhm.me
# --------------------------------------------------------

# --- Function Definitions ---

# 1. Install cloudflared
install_cloudflared() {
    echo "Installing cloudflared..."
    curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
    sudo dpkg -i cloudflared.deb
    sudo apt-get install -f -y
    rm cloudflared.deb
    echo "Cloudflared installation complete."
}

# 2. Uninstall cloudflared
uninstall_cloudflared() {
    echo "Uninstalling cloudflared..."
    sudo apt-get remove --purge cloudflared -y
    sudo apt-get autoremove -y
    echo "Cloudflared uninstallation complete."
}

# 3. Create a new tunnel
create_tunnel() {
    read -p "Enter the tunnel name: " tunnel_name
    cloudflared tunnel create "$tunnel_name"
    echo "Tunnel '$tunnel_name' created successfully."
}

# 4. Configure Tunnel with a YAML file
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

# 5. Delete a tunnel
delete_tunnel() {
    read -p "Enter the tunnel name to delete: " tunnel_name
    cloudflared tunnel delete "$tunnel_name"
    echo "Tunnel '$tunnel_name' deleted."
}

# 6. Cloudflare login
cloudflare_login() {
    cloudflared login
    echo "Cloudflare login successful."
}

# 7. Run the tunnel manually
run_tunnel_manually() {
    read -p "Enter the tunnel name: " tunnel_name
    read -p "Enter your username for tunnel files (e.g., $(whoami)): " username
    sudo cloudflared tunnel --config /home/$username/.cloudflared/${tunnel_name}.yml run
}

# 8. Create a systemd service
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

# 9. Enable and start the systemd service
enable_and_start_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl daemon-reload
    sudo systemctl enable cloudflared-$tunnel_name.service
    sudo systemctl start cloudflared-$tunnel_name.service
    echo "Service 'cloudflared-$tunnel_name' is active and enabled on boot."
}

# 10. Disable a systemd service
disable_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl disable cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' disabled."
}

# 11. Restart a systemd service
restart_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl restart cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' restarted."
}

# 12. Stop a systemd service
stop_service() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo systemctl stop cloudflared-$tunnel_name.service
    echo "Service for tunnel '$tunnel_name' stopped."
}

# 13. Delete a systemd service file
delete_service_file() {
    read -p "Enter the tunnel name: " tunnel_name
    sudo rm /etc/systemd/system/cloudflared-$tunnel_name.service
    sudo systemctl daemon-reload
    echo "Service file for tunnel '$tunnel_name' deleted."
}

# 14. Reload systemd
reload_systemd() {
    sudo systemctl daemon-reload
    echo "Systemd reloaded."
}

# 15. Verify tunnel status
verify_tunnel_status() {
    cloudflared tunnel list
}

# 16. Check system status
check_system_status() {
    echo "System Status:"
    echo "CPU Core(s): $(nproc)"
    echo "RAM Usage: $(free -h | awk '/^Mem/ {print $3 "/" $2}')"
    echo "Disk Usage: $(df -h / | awk '/\// {print $3 "/" $2}')"
    echo "Local IP Address: $(hostname -I | awk '{print $1}')"
}

# 17. Environment and process info
check_environment_processes() {
    echo "Cloudflared Environment Variables:"
    printenv | grep TUNNEL

    echo -e "\nCloudflared Processes:"
    ps aux | grep cloudflared

    echo -e "\nSystemd Services for Cloudflared:"
    systemctl list-units --type=service | grep cloudflared
}

# --- Main Menu ---
echo "Cloudflared Management Script"
echo "-----------------------------"
echo "1) Install cloudflared"
echo "2) Uninstall cloudflared"
echo "3) Create a new tunnel"
echo "4) Configure a tunnel with YAML file"
echo "5) Delete a tunnel"
echo "6) Cloudflare login"
echo "7) Run a tunnel manually"
echo "8) Create a systemd service"
echo "9) Enable and start the service"
echo "10) Disable the service"
echo "11) Restart the service"
echo "12) Stop the service"
echo "13) Delete the service file"
echo "14) Reload systemd"
echo "15) Verify tunnel status"
echo "16) Check system status"
echo "17) Check environment and processes"
echo "-----------------------------"
read -p "Enter your choice (1-17): " choice

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
    17) check_environment_processes ;;
    *) echo "Invalid option! Please choose a valid number (1-17)." ;;
esac
