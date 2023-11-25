#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Install Docker
curl -fsSL https://get.docker.com/ | CHANNEL=stable sh

# Enable and start Docker service (for systemd-based systems)
systemctl enable --now docker

# Install Docker Compose
apt update
apt install -y docker-compose

# Set up Docker Compose binary
LATEST=$(curl -Ls -w %{url_effective} -o /dev/null https://github.com/docker/compose/releases/latest)
LATEST=${LATEST##*/}
curl -L "https://github.com/docker/compose/releases/download/$LATEST/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Switch to /opt directory
cd /opt || exit

# Clone Mailcow repository
git clone https://github.com/mailcow/mailcow-dockerized
cd mailcow-dockerized

# Run configuration script
./generate_config.sh

# Pull and start Mailcow containers
docker-compose pull
docker-compose up -d

echo "Mailcow installation completed. Access the Mailcow web interface at http://your-server-ip:80"
