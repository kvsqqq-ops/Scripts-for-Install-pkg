#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}[*] Hi! This installer will install the following packages for you:${NC}"
echo "hyprland nano vim fastfetch firefox kitty thunar yay git hyprpaper grim yazi waybar"

sleep 1
echo "" 

echo -e "${RED}[*] Installing official packages...${NC}"
sudo pacman -S --needed base-devel hyprland nano vim fastfetch firefox kitty nemo hyprpaper waybar grim yazi code git --noconfirm

if ! command -v yay &> /dev/null; then
    echo -e "${RED}[*] yay not found. Installing from AUR...${NC}"
    BUILD_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$BUILD_DIR"
    cd "$BUILD_DIR" || exit
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf "$BUILD_DIR"
    echo -e "${RED}[+] yay installed successfully!${NC}"
else
    echo -e "${RED}[!] yay is already installed.${NC}"
fi

echo -e "${RED}[*] Applying Xora branding...${NC}"

FF_SCRIPT="./fastfetch/fastfetch.sh"

if [ -f "$FF_SCRIPT" ]; then
    chmod +x "$FF_SCRIPT"
    bash "$FF_SCRIPT"
else
    if [ -f "./fastfetch/logo.txt" ]; then
        fastfetch --source ./fastfetch/logo.txt
    else
        echo -e "${RED}[!] Custom logo not found, running standard fastfetch.${NC}"
        fastfetch
    fi
fi

echo -e "${RED}[+] All done! Welcome to Xora Linux.${NC}"
