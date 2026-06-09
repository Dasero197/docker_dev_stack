#!/bin/bash
# ==============================================================================
# setup-vault-manager.sh
# Automates the setup of Syncthing and KeePassXC for decentralized vault management.
# ==============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}  Setup: Decentralized Vault Manager (Syncthing)    ${NC}"
echo -e "${BLUE}====================================================${NC}"

# 1. Detect OS
echo -e "\n${YELLOW}[1/5] Detecting Operating System...${NC}"
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          echo -e "${RED}Unsupported OS: ${OS}${NC}"; exit 1;;
esac
echo -e "${GREEN}Detected: ${MACHINE}${NC}"

# 2. Configure Sync Directory
echo -e "\n${YELLOW}[2/5] Configuring Sync Directory...${NC}"
DEFAULT_SYNC_DIR="$HOME/Documents/Vaults_Clients"
read -p "Enter the absolute path for your Sync folder [$DEFAULT_SYNC_DIR]: " USER_SYNC_DIR
SYNC_DIR=${USER_SYNC_DIR:-$DEFAULT_SYNC_DIR}

# Resolve ~ to $HOME
SYNC_DIR="${SYNC_DIR/#\~/$HOME}"

if [ ! -d "$SYNC_DIR" ]; then
    echo -e "Directory does not exist. Creating ${SYNC_DIR}..."
    mkdir -p "$SYNC_DIR"
    chmod 700 "$SYNC_DIR"
    echo -e "${GREEN}Directory created and secured (chmod 700).${NC}"
else
    echo -e "${GREEN}Directory already exists.${NC}"
    chmod 700 "$SYNC_DIR"
fi

# Update .env file
ENV_FILE="$(dirname "$0")/../.env"
if [ -f "$ENV_FILE" ]; then
    # Replace or add SYNCTHING_SYNC_DIR
    if grep -q "^SYNCTHING_SYNC_DIR=" "$ENV_FILE"; then
        # Use a comma as delimiter for sed to avoid conflicts with slashes in paths
        sed -i.bak "s,^SYNCTHING_SYNC_DIR=.*,SYNCTHING_SYNC_DIR=${SYNC_DIR}," "$ENV_FILE"
        rm -f "${ENV_FILE}.bak"
    else
        echo "SYNCTHING_SYNC_DIR=${SYNC_DIR}" >> "$ENV_FILE"
    fi
    echo -e "${GREEN}Updated .env file with SYNCTHING_SYNC_DIR=${SYNC_DIR}${NC}"
else
    echo -e "${RED}WARNING: .env file not found at $ENV_FILE. Make sure you run setup-hosts.sh first.${NC}"
fi

# 3. Check Docker and Syncthing Container
echo -e "\n${YELLOW}[3/5] Checking Docker status...${NC}"
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker is not installed! Please install Docker and try again.${NC}"
    exit 1
fi
echo -e "${GREEN}Docker is installed.${NC}"

echo -e "Checking if 'syncthing' container is running..."
if docker ps --format '{{.Names}}' | grep -q "^syncthing$"; then
    echo -e "${GREEN}Syncthing container is running.${NC}"
else
    echo -e "${YELLOW}Syncthing container is NOT running.${NC}"
    echo -e "Starting it now..."
    (cd "$(dirname "$0")/.." && docker compose --profile sync up -d syncthing)
    echo -e "${GREEN}Syncthing started.${NC}"
fi

# 4. Check/Install KeePassXC
echo -e "\n${YELLOW}[4/5] Checking KeePassXC installation...${NC}"
if command -v keepassxc >/dev/null 2>&1; then
    echo -e "${GREEN}KeePassXC is already installed.${NC}"
else
    echo -e "${YELLOW}KeePassXC is not installed.${NC}"
    read -p "Do you want to install KeePassXC now? (y/n): " INSTALL_KP
    if [[ "$INSTALL_KP" =~ ^[Yy]$ ]]; then
        if [ "$MACHINE" == "Linux" ]; then
            if command -v apt >/dev/null 2>&1; then
                echo -e "Installing via apt..."
                sudo apt update && sudo apt install -y keepassxc
            else
                echo -e "${RED}apt not found. Please install KeePassXC manually: https://keepassxc.org/${NC}"
            fi
        elif [ "$MACHINE" == "Mac" ]; then
            if command -v brew >/dev/null 2>&1; then
                echo -e "Installing via Homebrew..."
                brew install --cask keepassxc
            else
                echo -e "${RED}Homebrew not found. Please install KeePassXC manually: https://keepassxc.org/${NC}"
            fi
        fi
        echo -e "${GREEN}KeePassXC installation complete.${NC}"
    else
        echo -e "Skipping KeePassXC installation."
    fi
fi

# 5. Success & Instructions
echo -e "\n${YELLOW}[5/5] Finalizing setup...${NC}"
sleep 1 # Wait for syncthing to initialize

echo -e "${BLUE}====================================================${NC}"
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e ""
echo -e "Your Syncthing GUI is available at:"
echo -e "👉 ${GREEN}http://syncthing.local${NC} (or http://localhost:8384)"
echo -e ""
echo -e "Your synced directory is at: ${GREEN}${SYNC_DIR}${NC}"
echo -e ""
echo -e "Next steps:"
echo -e "1. Open the Syncthing GUI in your browser."
echo -e "2. Go to 'Actions' -> 'Show ID' to get your Device ID."
echo -e "3. Open KeePassXC and create/save your .kdbx files inside ${SYNC_DIR}."
echo -e ""
echo -e "Happy hacking and stay secure! 🔐"
