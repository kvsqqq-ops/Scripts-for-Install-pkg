#!/bin/bash

# Цвета Xora
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Определяем путь к текущему скрипту
SCRIPT_PATH="$(realpath "$0")"
SCRIPT_NAME="XoraOpt"
TARGET_PATH="/usr/local/bin/$SCRIPT_NAME"

# ---------------------------
# УСТАНОВКА СКРИПТА В СИСТЕМУ
# ---------------------------

echo -e "${YELLOW}[*] Installing $SCRIPT_NAME to system...${NC}"

# Проверяем, запущен ли скрипт уже из целевого расположения
if [[ "$SCRIPT_PATH" != "$TARGET_PATH" ]]; then
    echo -e "${GREEN}[*] Copying script to $TARGET_PATH${NC}"
    
    # Копируем скрипт в /usr/local/bin
    sudo cp "$SCRIPT_PATH" "$TARGET_PATH"
    
    # Делаем его исполняемым
    sudo chmod +x "$TARGET_PATH"
    
    echo -e "${GREEN}[✓] Script installed to $TARGET_PATH${NC}"
    
    # Добавляем алиас в оболочки
    echo -e "${GREEN}[*] Adding alias to shell configs...${NC}"
    
    # Для bash
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "alias $SCRIPT_NAME=" "$HOME/.bashrc"; then
            echo "alias $SCRIPT_NAME='sudo $TARGET_PATH'" >> "$HOME/.bashrc"
            echo -e "${GREEN}[✓] Alias added to ~/.bashrc${NC}"
        else
            echo -e "${YELLOW}[!] Alias already exists in ~/.bashrc${NC}"
        fi
    fi
    
    # Для zsh
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias $SCRIPT_NAME=" "$HOME/.zshrc"; then
            echo "alias $SCRIPT_NAME='sudo $TARGET_PATH'" >> "$HOME/.zshrc"
            echo -e "${GREEN}[✓] Alias added to ~/.zshrc${NC}"
        else
            echo -e "${YELLOW}[!] Alias already exists in ~/.zshrc${NC}"
        fi
    fi
    
    # Для fish (если используется)
    if [ -d "$HOME/.config/fish" ]; then
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        if [ -f "$FISH_CONFIG" ]; then
            if ! grep -q "alias $SCRIPT_NAME=" "$FISH_CONFIG"; then
                echo "alias $SCRIPT_NAME='sudo $TARGET_PATH'" >> "$FISH_CONFIG"
                echo -e "${GREEN}[✓] Alias added to fish config${NC}"
            fi
        fi
    fi
    
    echo -e "${GREEN}[✓] Installation complete!${NC}"
    echo -e "${YELLOW}[!] Please run: source ~/.bashrc (or restart your terminal)${NC}"
    echo -e "${GREEN}[!] Then you can use: $SCRIPT_NAME or XoraOpt${NC}"
    echo -e "${RED}[*] Running cleanup now...${NC}\n"
else
    echo -e "${GREEN}[*] Script already installed, running cleanup...${NC}\n"
fi

# ---------------------------
# ОСНОВНАЯ ЧАСТЬ СКРИПТА (CLEANUP)
# ---------------------------

# Проверка на root права
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] This script must be run as root! Use: sudo XoraOpt${NC}" 
   exit 1
fi

echo -e "${RED}[*] Xora autostart cleanup...${NC}"

# ---------------------------
# SYSTEM SERVICES CLEANUP
# ---------------------------

echo -e "${GREEN}[1/5] Disabling unnecessary system services...${NC}"

SERVICES=(
    "bluetooth.service"
    "cups.service"
    "avahi-daemon.service"
    "ModemManager.service"
    "rpcbind.service"
    "nfs-client.target"
    "nfs-server.service"
    "docker.service"
    "libvirtd.service"
    "rpcbind.socket"
)

for svc in "${SERVICES[@]}"; do
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
        systemctl disable --now "$svc" 2>/dev/null
        echo -e "${GREEN}[✓] Disabled: $svc${NC}"
    fi
done

echo -e "${GREEN}[2/5] Cleaning user autostart...${NC}"

USER_SERVICES=(
    "bluetooth.service"
)

for svc in "${USER_SERVICES[@]}"; do
    if systemctl --user is-enabled --quiet "$svc" 2>/dev/null; then
        systemctl --user disable --now "$svc" 2>/dev/null
        echo -e "${GREEN}[✓] Disabled user service: $svc${NC}"
    fi
done

echo -e "${GREEN}[3/5] Masking unused services...${NC}"

MASKED=(
    "bluetooth.service"
    "cups.service"
    "avahi-daemon.service"
)

for svc in "${MASKED[@]}"; do
    if ! systemctl is-masked --quiet "$svc" 2>/dev/null; then
        systemctl mask "$svc" 2>/dev/null
        echo -e "${GREEN}[✓] Masked: $svc${NC}"
    fi
done

echo -e "${GREEN}[4/5] Cleaning desktop autostart entries...${NC}"

if [ -d ~/.config/autostart ]; then
    rm -f ~/.config/autostart/*.desktop 2>/dev/null
    echo -e "${GREEN}[✓] Cleaned ~/.config/autostart/${NC}"
fi

if [ -d ~/.config/autostart-scripts ]; then
    rm -f ~/.config/autostart-scripts/* 2>/dev/null
    echo -e "${GREEN}[✓] Cleaned ~/.config/autostart-scripts/${NC}"
fi

echo -e "${GREEN}[5/5] Advanced tweaks...${NC}"

# Очистка логов (оставляем последние 2 дня)
journalctl --vacuum-time=2d --quiet 2>/dev/null
echo -e "${GREEN}[✓] Logs cleaned (kept 2 days)${NC}"

# Обновление базы пакетов
pacman-db-upgrade 2>/dev/null
echo -e "${GREEN}[✓] Pacman database upgraded${NC}"

# Показ failed сервисов
FAILED_SERVICES=$(systemctl --failed --no-legend 2>/dev/null | wc -l)
if [ "$FAILED_SERVICES" -gt 0 ]; then
    echo -e "${YELLOW}[!] Found $FAILED_SERVICES failed services:${NC}"
    systemctl --failed --no-pager 2>/dev/null
else
    echo -e "${GREEN}[✓] No failed services${NC}"
fi

# Очистка кэша pacman (оставляем 2 последние версии)
if command -v paccache &> /dev/null; then
    sudo paccache -r -k 2 2>/dev/null
    echo -e "${GREEN}[✓] Pacman cache cleaned (kept 2 versions)${NC}"
else
    echo -e "${YELLOW}[!] paccache not found (install pacman-contrib)${NC}"
fi

echo -e "\n${GREEN}=== Cleanup Summary ===${NC}"
echo -e "${GREEN}[✓] Disabled ${#SERVICES[@]} system services${NC}"
echo -e "${GREEN}[✓] Disabled ${#USER_SERVICES[@]} user services${NC}"
echo -e "${GREEN}[✓] Masked ${#MASKED[@]} services${NC}"
echo -e "${GREEN}[✓] Cleaned autostart entries${NC}"
echo -e "${GREEN}[✓] Applied system tweaks${NC}"

echo -e "\n${RED}[+] Done. Reboot recommended.${NC}"
echo -e "${YELLOW}[!] Run: sudo reboot now${NC}"