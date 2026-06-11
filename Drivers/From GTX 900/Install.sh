#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}[*] Starting NVIDIA 580xx Open-DKMS installation...${NC}"

echo -e "${RED}[*] Detecting kernel and installing headers...${NC}"
if uname -r | grep -q "zen"; then
    HEADERS="linux-zen-headers"
elif uname -r | grep -q "lts"; then
    HEADERS="linux-lts-headers"
else
    HEADERS="linux-headers"
fi

echo -e "${RED}[*] Installing headers: $HEADERS...${NC}"
sudo pacman -S --needed "$HEADERS" --noconfirm

echo -e "${RED}[*] Installing DKMS...${NC}"
sudo pacman -S --needed dkms --noconfirm

echo -e "${RED}[*] Blacklisting Nouveau...${NC}"
sudo bash -c "cat > /etc/modprobe.d/nouveau-blacklist.conf" << EOF
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo -e "${RED}[*] Disabling Nouveau via GRUB...${NC}"
GRUB_CONFIG="/etc/default/grub"
NOUVEAU_OPTIONS="nouveau.modeset=0 rdblacklist=nouveau nouveau.blacklist=1"

if [ -f "$GRUB_CONFIG" ]; then
    if grep -q "GRUB_CMDLINE_LINUX=" "$GRUB_CONFIG"; then
        if ! grep -q "nouveau.modeset=0" "$GRUB_CONFIG"; then
            sudo sed -i "s/GRUB_CMDLINE_LINUX=\"[^\"]*\"/GRUB_CMDLINE_LINUX=\"& $NOUVEAU_OPTIONS\"/" "$GRUB_CONFIG"
        fi
    else
        echo "GRUB_CMDLINE_LINUX=\"$NOUVEAU_OPTIONS\"" | sudo tee -a "$GRUB_CONFIG"
    fi

    echo -e "${RED}[*] Regenerating GRUB configuration...${NC}"
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    echo -e "${RED}[!] GRUB config not found${NC}"
fi

# 5. NVIDIA
echo -e "${RED}[*] Installing NVIDIA Open 580xx DKMS...${NC}"
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
else
    echo -e "${RED}[!] No AUR helper found. Installing yay...${NC}"
    sudo pacman -S --needed git base-devel --noconfirm
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit 1
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    AUR_HELPER="yay"
fi

$AUR_HELPER -S --needed nvidia-580xx-dkms nvidia-580xx-utils --noconfirm

echo -e "${RED}[*] Regenerating initramfs...${NC}"
sudo mkinitcpio -P

echo ''
echo -e "${RED}[+] Done! NVIDIA 580xx DKMS installed.${NC}"
echo -e "${RED}[!] Reboot now.${NC}"
echo -e "${RED}[!] After reboot check: lsmod | grep -E 'nouveau|nvidia'${NC}"