#!/usr/bin/env bash

# ==========================================================
#                  EVILSAAD BOT INSTALLER
# ==========================================================

set -Eeuo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
RESET='\033[0m'

REPO_URL="https://github.com/evilsaad9918-lgtm/vps.git"
INSTALL_DIR="vps"

banner() {
    clear || true
    echo -e "${PURPLE}"
    echo "███████╗██╗   ██╗██╗██╗      ███████╗ █████╗  █████╗ ██████╗"
    echo "██╔════╝██║   ██║██║██║      ██╔════╝██╔══██╗██╔══██╗██╔══██╗"
    echo "█████╗  ██║   ██║██║██║      ███████╗███████║███████║██║  ██║"
    echo "██╔══╝  ╚██╗ ██╔╝██║██║      ╚════██║██╔══██║██╔══██║██║  ██║"
    echo "███████╗ ╚████╔╝ ██║███████╗ ███████║██║  ██║██║  ██║██████╔╝"
    echo "╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}              BOT INSTALLATION MENU${RESET}"
    echo -e "${YELLOW}==========================================================${RESET}"
    echo
}

pause() {
    echo
    read -r -p "Press Enter to continue..."
}

step() {
    echo -e "\n${CYAN}[+] $1${RESET}"
}

success() {
    echo -e "${GREEN}[✓] $1${RESET}"
}

fail() {
    echo -e "${RED}[✗] $1${RESET}"
    exit 1
}

install_bot() {
    banner
    echo -e "${GREEN}Starting bot installation...${RESET}"

    if [[ $EUID -ne 0 ]]; then
        fail "Please run this installer as root: sudo bash install.sh"
    fi

    step "Checking and cleaning temporary package caches"
    # Safe cache cleanup only; this does not remove user project files.
    apt-get clean || true
    rm -rf /var/lib/apt/lists/*
    if command -v pip3 >/dev/null 2>&1; then
        pip3 cache purge >/dev/null 2>&1 || true
    fi
    rm -rf /root/.cache/pip

    AVAILABLE_KB=$(df -Pk . | awk 'NR==2 {print $4}')
    if [[ -z "${AVAILABLE_KB:-}" || "$AVAILABLE_KB" -lt 307200 ]]; then
        echo -e "${RED}[✗] Not enough free disk space. At least 300 MB is required.${RESET}"
        df -h .
        echo -e "${YELLOW}Free space in your Railway service/container, or increase its storage, then run this installer again.${RESET}"
        fail "Disk space check failed"
    fi

    step "Updating package lists"
    apt-get update || fail "apt update failed"

    step "Installing required system packages"
    apt-get install -y git unzip python3 python3-pip python3-venv nano \
        || fail "Could not install required packages"

    step "Downloading bot repository"
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        echo -e "${YELLOW}Repository already exists. Using existing folder.${RESET}"
    elif [[ -e "$INSTALL_DIR" ]]; then
        fail "'$INSTALL_DIR' exists but is not a Git repository. Rename or remove it first."
    else
        git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || { df -h .; fail "Git clone failed. Check available disk space with: df -h"; }
    fi

    cd "$INSTALL_DIR" || fail "Could not enter $INSTALL_DIR"

    step "Checking bot archive"
    if [[ ! -f "docker-bot.zip" ]]; then
        fail "docker-bot.zip was not found inside $INSTALL_DIR. Check the repository files."
    fi

    step "Extracting bot files"
    unzip -o "docker-bot.zip" || fail "Could not extract docker-bot.zip"

    step "Preparing Python virtual environment"
    python3 -m venv .venv || fail "Could not create Python virtual environment"

    step "Installing Python dependencies"
    .venv/bin/python -m pip install --upgrade pip || fail "pip upgrade failed"
    .venv/bin/python -m pip install discord dotenv PyNaCl davey \
        || fail "Python dependency installation failed"

    step "Creating .env configuration"
    if [[ -f ".env" ]]; then
        echo -e "${YELLOW}.env already exists; keeping the existing file.${RESET}"
    elif [[ -f "env" ]]; then
        cp "env" ".env"
        success "Copied env to .env"
    else
        echo -e "${YELLOW}No env template found. Creating an empty .env file.${RESET}"
        touch .env
    fi

    success "Bot files and dependencies are ready."
    echo
    echo -e "${YELLOW}Next step: configure your bot settings in .env${RESET}"
    if command -v nano >/dev/null 2>&1; then
        read -r -p "Open .env now? [Y/n]: " answer
        if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
            nano .env
        fi
    fi

    echo
    success "Installation completed."
    echo -e "${CYAN}Bot directory: $(pwd)${RESET}"
    echo -e "${CYAN}Python environment: $(pwd)/.venv${RESET}"
    echo -e "${YELLOW}To start the bot, use the bot's actual Python entry file with .venv/bin/python.${RESET}"
    pause
}

while true; do
    banner
    echo -e "${GREEN}1) INSTALL BOT${RESET}"
    echo -e "${RED}2) EXIT${RESET}"
    echo
    read -r -p "Select an option [1-2]: " choice

    case "$choice" in
        1) install_bot ;;
        2)
            echo -e "${YELLOW}Exiting installer. Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please select 1 or 2.${RESET}"
            sleep 1
            ;;
    esac
done
