#!/bin/bash

# ============================================================
#              EVILSAAD DOCKER VPS BOT INSTALLER
# ============================================================

set -e

REPO_URL="https://github.com/evilsaad9918-lgtm/vps.git"
PROJECT_DIR="vps"
ZIP_FILE="EVILSAAD-Docker-VPS-Bot.zip"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

banner() {
    clear
    echo -e "${CYAN}"
    echo "============================================================"
    echo "  ███████╗██╗   ██╗██╗██╗      ███████╗ █████╗  █████╗ ██████╗"
    echo "  ██╔════╝██║   ██║██║██║      ██╔════╝██╔══██╗██╔══██╗██╔══██╗"
    echo "  █████╗  ██║   ██║██║██║      ███████╗███████║███████║██║  ██║"
    echo "  ██╔══╝  ╚██╗ ██╔╝██║██║      ╚════██║██╔══██║██╔══██║██║  ██║"
    echo "  ███████╗ ╚████╔╝ ██║███████╗ ███████║██║  ██║██║  ██║██████╔╝"
    echo "  ╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
    echo "============================================================"
    echo "                 DOCKER VPS BOT INSTALLER"
    echo "                    MADE BY EVILSAAD"
    echo "============================================================"
    echo -e "${RESET}"
}

step() {
    echo
    echo -e "${YELLOW}[$1/7] $2${RESET}"
    echo "------------------------------------------------------------"
}

install_bot() {

    banner

    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Please run this installer as root.${RESET}"
        return 1
    fi

    if ! command -v apt-get >/dev/null 2>&1; then
        echo -e "${RED}Ubuntu/Debian with APT is required.${RESET}"
        return 1
    fi

    step 1 "Updating package lists"
    apt-get update

    step 2 "Installing required packages"
    apt-get install -y unzip python3-pip git nano

    step 3 "Downloading GitHub repository"

    if [[ -d "$PROJECT_DIR/.git" ]]; then
        echo "Repository already exists."
    elif [[ -e "$PROJECT_DIR" ]]; then
        echo "ERROR: $PROJECT_DIR exists but is not a Git repository."
        return 1
    else
        git clone "$REPO_URL" "$PROJECT_DIR"
    fi

    step 4 "Installing Python dependencies"

    python3 -m pip install --break-system-packages \
        discord \
        dotenv \
        PyNaCl \
        davey

    step 5 "Extracting Docker VPS Bot"

    cd "$PROJECT_DIR"

    if [[ ! -f "$ZIP_FILE" ]]; then
        echo -e "${RED}ERROR: $ZIP_FILE not found!${RESET}"
        return 1
    fi

    unzip -o "$ZIP_FILE"

    step 6 "Creating environment configuration"

    if [[ -f env ]]; then
        cp -f env .env
    elif [[ -f .env ]]; then
        echo ".env already exists."
    else
        echo "ERROR: env template not found."
        return 1
    fi

    step 7 "Configuring Discord Bot"

    nano .env

    echo
    echo -e "${GREEN}"
    echo "============================================================"
    echo "              INSTALLATION COMPLETED!"
    echo "============================================================"
    echo " Project: $PROJECT_DIR"
    echo " Config:  .env"
    echo "============================================================"
    echo -e "${RESET}"

    echo "Start your bot using its appropriate Python entry-point."
    echo "============================================================"
}

while true; do

    banner

    echo -e "${GREEN}SELECT AN OPTION:${RESET}"
    echo
    echo "  1) INSTALL DOCKER BOT"
    echo
    echo "  2) EXIT"
    echo
    echo "============================================================"

    read -rp "Select Option [1-2]: " choice

    case "$choice" in

        1)
            install_bot
            read -rp "Press ENTER to return to menu..."
            ;;

        2)
            echo -e "${YELLOW}Exiting installer...${RESET}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid option!${RESET}"
            sleep 2
            ;;

    esac

done
