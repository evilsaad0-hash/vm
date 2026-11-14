#!/bin/bash

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}"
cat << 'EOF'
$$$$$$$$\ $$\    $$\ $$$$$$\ $$\       $$$$$$\   $$$$$$\   $$$$$$\  $$$$$$$\
$$  _____|$$ |   $$ |\_$$  _|$$ |     $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\
$$ |      $$ |   $$ |  $$ |  $$ |     $$ /  \__|$$ /  $$ |$$ /  $$ |$$ |  $$ |
$$$$$\    \$$\  $$  |  $$ |  $$ |     \$$$$$$\  $$$$$$$$ |$$$$$$$$ |$$ |  $$ |
$$  __|    \$$\$$  /   $$ |  $$ |      \____$$\ $$  __$$ |$$  __$$ |$$ |  $$ |
$$ |        \$$$  /    $$ |  $$ |     $$\   $$ |$$ |  $$ |$$ |  $$ |$$ |  $$ |
$$$$$$$$\    \$  /   $$$$$$\ $$$$$$$$\\$$$$$$  |$$ |  $$ |$$ |  $$ |$$$$$$$  |
\________|    \_/    \______|\________|\______/ \__|  \__|\__|  \__|\_______/
EOF

echo ""
echo -e "          ${GREEN}LXC INSTALLER FULL SETUP${NC}"
echo ""

echo -e "${GREEN}[1]${NC} Install LXC (Full Setup)"
echo -e "${RED}[2]${NC} Exit"
echo ""

read -r -p "Select an option: " choice

# Remove hidden whitespace / carriage-return characters from terminal input.
choice="$(printf '%s' "$choice" | tr -d '[:space:]')"

case "$choice" in

1)
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root!${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Updating packages...${NC}"
    apt-get update

    echo -e "${YELLOW}Installing LXC packages...${NC}"
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        lxc \
        lxc-utils \
        lxc-templates \
        uidmap \
        bridge-utils \
        dnsmasq-base \
        iptables

    echo -e "${YELLOW}Configuring LXC network...${NC}"

    cat > /etc/default/lxc-net <<EOF
USE_LXC_BRIDGE=true
LXC_BRIDGE=lxcbr0
LXC_ADDR=10.0.3.1
LXC_NETMASK=255.255.255.0
LXC_NETWORK=10.0.3.0/24
LXC_DHCP_RANGE=10.0.3.2,10.0.3.254
LXC_DHCP_MAX=253
EOF

    modprobe bridge
    sysctl -w net.ipv4.ip_forward=1

    if [ -f /etc/sysctl.conf ]; then
        sed -i '/^net.ipv4.ip_forward=/d' /etc/sysctl.conf
        echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    fi

    systemctl enable lxc-net
    systemctl restart lxc-net

    echo ""
    echo -e "${GREEN}LXC INSTALLATION COMPLETED!${NC}"
    echo ""

    lxc-checkconfig

    echo ""
    echo -e "${CYAN}Bridge Information:${NC}"
    ip addr show lxcbr0 2>/dev/null

    echo ""
    echo -e "${GREEN}Made by EVILSAAD${NC}"
    ;;

2)
    echo -e "${RED}Exiting...${NC}"
    exit 0
    ;;

*)
    echo -e "${RED}Invalid option!${NC}"
    exit 1
    ;;

esac