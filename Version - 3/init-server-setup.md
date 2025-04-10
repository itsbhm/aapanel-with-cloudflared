sudo apt install openssh-server
sudo ufw allow ssh
sudo systemctl status ssh
sudo systemctl start ssh
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v
npm -
timedatectl
timedatectl list-timezones | grep Asia
sudo timedatectl set-timezone Asia/Kolkata