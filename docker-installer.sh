#!/bin/bash

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear

banner() {
echo -e "${RED}"
echo " ███████╗██╗   ██╗██╗██╗      ███████╗ █████╗  █████╗ ██████╗"
echo " ██╔════╝██║   ██║██║██║      ██╔════╝██╔══██╗██╔══██╗██╔══██╗"
echo " █████╗  ██║   ██║██║██║      ███████╗███████║███████║██║  ██║"
echo " ██╔══╝  ╚██╗ ██╔╝██║██║      ╚════██║██╔══██║██╔══██║██║  ██║"
echo " ███████╗ ╚████╔╝ ██║███████╗ ███████║██║  ██║██║  ██║██████╔╝"
echo " ╚══════╝  ╚═══╝  ╚═╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝"
echo -e "${NC}"
echo -e "${CYAN}============================================${NC}"
echo -e "${GREEN}          DOCKER VPS INSTALLER${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""
}

install_docker() {

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[ERROR] Please run as root!${NC}"
    return
fi

step() {
    echo ""
    echo -e "${YELLOW}[$1/5] $2${NC}"
}

step 1 "Updating VPS..."
apt update -y || return

echo -e "${GREEN}[SUCCESS] VPS Updated!${NC}"

step 2 "Installing Docker..."
apt install docker.io -y || return

echo -e "${GREEN}[SUCCESS] Docker Installed!${NC}"

step 3 "Installing Neofetch..."
apt install neofetch -y

step 4 "Starting Docker..."

systemctl stop docker 2>/dev/null

if pgrep -x dockerd >/dev/null; then
    pkill -x dockerd
    sleep 2
fi

nohup dockerd --iptables=false --bridge=none \
    >/var/log/dockerd.log 2>&1 &

echo "Waiting for Docker..."

for i in {1..30}; do
    if docker info >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}[ERROR] Docker failed to start!${NC}"
    echo "Check /var/log/dockerd.log"
    return
fi

echo -e "${GREEN}[SUCCESS] Docker Running!${NC}"

step 5 "Checking Installation..."

docker --version
docker info --format 'Docker Server: {{.ServerVersion}}'

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}       INSTALLATION COMPLETED!${NC}"
echo -e "${GREEN}============================================${NC}"

if command -v neofetch >/dev/null 2>&1; then
    neofetch
fi

echo ""
read -p "Press ENTER to return to menu..."
}

while true; do

    clear
    banner

    echo -e "${GREEN}[1]${NC} INSTALL DOCKER"
    echo -e "${RED}[2]${NC} EXIT"

    echo ""
    echo -e "${CYAN}============================================${NC}"

    read -p "Select Option: " choice

    case $choice in

        1)
            install_docker
            ;;

        2)
            clear
            echo -e "${GREEN}Thanks for using EVILSAAD!${NC}"
            exit 0
            ;;

        *)
            echo -e "${RED}Invalid Option!${NC}"
            sleep 2
            ;;

    esac

done
