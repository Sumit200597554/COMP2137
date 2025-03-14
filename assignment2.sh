#!/bin/bash

# Notify the user the script has started
echo "Starting script to configure server1..."

# Step 1: Set IP address to 192.168.16.21/24
echo "Setting IP address to 192.168.16.21/24..."
sudo bash -c 'echo "network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.16.21/24" > /etc/netplan/01-netcfg.yaml'

# Apply the netplan configuration
sudo netplan apply
echo "IP address set to 192.168.16.21."

# Step 2: Update /etc/hosts to reflect the correct IP and hostname
echo "Updating /etc/hosts..."
sudo bash -c 'echo "192.168.16.21 server1" >> /etc/hosts'
sudo sed -i '/192.168.16.21/!d' /etc/hosts
echo "/etc/hosts updated."

# Step 3: Install apache2 and squid if not already installed
echo "Checking and installing apache2..."
if ! command -v apache2 &> /dev/null
then
    echo "apache2 not found, installing..."
    sudo apt update && sudo apt install -y apache2
else
    echo "apache2 is already installed."
fi

echo "Checking and installing squid..."
if ! command -v squid &> /dev/null
then
    echo "squid not found, installing..."
    sudo apt install -y squid
else
    echo "squid is already installed."
fi

# Step 4: Set up user accounts with SSH keys and sudo
echo "Setting up user accounts..."

# User list
users=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")

# Adding users and configuring SSH keys
for user in "${users[@]}"
do
    echo "Setting up user: $user"
    sudo useradd -m -s /bin/bash $user
    sudo mkdir -p /home/$user/.ssh
    sudo ssh-keygen -t rsa -b 4096 -f /home/$user/.ssh/id_rsa -N "" -q
    sudo ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N "" -q
    sudo cat /home/$user/.ssh/id_rsa.pub >> /home/$user/.ssh/authorized_keys
    sudo cat /home/$user/.ssh/id_ed25519.pub >> /home/$user/.ssh/authorized_keys
    sudo chown -R $user:$user /home/$user/.ssh
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/authorized_keys
    sudo usermod -aG sudo $user
    echo "User $user setup complete."
done

# Notify that the script is finished
echo "Server1 configuration complete."
