#!/bin/bash

# ==========================================
#       EVILSAAD DOCKER BOT INSTALLER
# ==========================================

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
RESET='\033[0m'

REPO="https://github.com/evilsaad9918-lgtm/vps.git"

banner() {
clear

echo -e "${PURPLE}"
echo "███████╗██╗   ██╗██╗██╗      ███████╗ █████╗  █████╗ ██████╗"
echo "██╔════╝██║   ██║██║██║      ██╔════╝██╔══██╗██╔══██╗██╔══██╗"
echo "█████╗  ██║   ██║██║██║      ███████╗███████║███████║██║  ██║"
echo "██╔══╝  ╚██╗ ██╔╝██║██║      ╚════██║██╔══██║██╔══██║██║  ██║"
echo "███████╗ ╚████╔╝ ██║███████╗ ███████║██║  ██║██║  ██║██████╔╝"
echo "╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
echo ""
echo "              DOCKER BOT INSTALLER"
echo "                 MADE BY EVILSAAD"
echo "=========================================================="
echo -e "${RESET}"
}

pause() {
    echo ""
    read -p "Press ENTER to continue..."
}

install_bot() {

    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Please run as root!${RESET}"
        return 1
    fi

    echo -e "${CYAN}[1/7] Updating packages...${RESET}"
    apt update || return 1

    echo -e "${CYAN}[2/7] Installing dependencies...${RESET}"
    apt install unzip python3-pip git nano -y || return 1

    echo -e "${CYAN}[3/7] Cloning repository...${RESET}"

    if [[ ! -d vps ]]; then
        git clone "$REPO" vps || return 1
    else
        echo -e "${YELLOW}Repository folder already exists.${RESET}"
    fi

    cd vps || return 1

    echo -e "${CYAN}[4/7] Installing Python modules...${RESET}"
    python3 -m pip install --break-system-packages \
        discord dotenv PyNaCl davey || return 1

    echo -e "${CYAN}[5/7] Extracting Docker Bot...${RESET}"

    if [[ ! -f docker-bot.zip ]]; then
        echo -e "${RED}docker-bot.zip not found!${RESET}"
        return 1
    fi

    unzip -o docker-bot.zip || return 1

    echo -e "${CYAN}[6/7] Creating ENV file...${RESET}"

    if [[ -f env ]]; then
        cp -n env .env
    elif [[ ! -f .env ]]; then
        echo -e "${RED}ENV file not found!${RESET}"
        return 1
    fi

    echo -e "${CYAN}[7/7] Configuring bot...${RESET}"

    nano .env

    echo ""
    echo -e "${GREEN}"
    echo "================================================"
    echo "          INSTALLATION COMPLETED!"
    echo "================================================"
    echo -e "${RESET}"

    echo "Project directory: $(pwd)"
    echo "Configuration: .env"
    echo ""
    echo "Bot source installation completed."
    echo "Start command must be configured for your bot."
}

while true
do

    banner

    echo -e "${GREEN} [1] INSTALL DOCKER BOT ${RESET}"
    echo -e "${RED} [2] EXIT ${RESET}"

    echo ""
    read -p " Select Option: " option

    case $option in

        1)
            echo ""
            install_bot
            pause
            ;;

        2)
            echo -e "${YELLOW}Thanks for using EVILSAAD installer!${RESET}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid option!${RESET}"
            sleep 2
            ;;

    esac

done
