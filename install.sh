#!/bin/bash

# Ensure the script is run with sudo privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run with sudo"
  exit 1
fi

# Update package list
echo "Updating package list..."
apt update

# Install common dependencies
echo "Installing common dependencies..."
apt install -y \
  build-essential \
  curl \
  git \
  vim \
  htop \
  neofetch

# Install C++ (g++ and build-essential)
echo "Installing C++ (g++ and build-essential)..."
apt install -y g++ build-essential

# Install Python
echo "Installing Python..."
apt install -y python3 python3-pip

# Install Docker
echo "Installing Docker..."
apt install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Install Rust
echo "Installing Rust..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sudo apt install cargo

# Install btop
echo "Installing btop..."
curl -fsSL https://github.com/aristocratos/btop/releases/latest/download/btop-x86_64-linux-musl.tbz | tar -xj -C /usr/local/bin

# Install Git (if not installed)
echo "Installing Git..."
apt install -y git

# Install Docker Compose (optional but recommended)
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Vim (optional if not already installed)
echo "Installing Vim..."
apt install -y vim

# Finish up
echo "Installation complete!"

# Verify installations
echo "Verifying installations..."
g++ --version
rustc --version
python3 --version
docker --version
htop --version
btop --version
neofetch --version
git --version
curl --version

echo "All tools installed successfully."
