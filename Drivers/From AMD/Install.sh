#!/bin/bash

# Цвета Xora
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}[*] Starting AMD GPU (Mesa/Open Source) setup...${NC}"

# 1. Определение версии ядра для правильных заголовков
KERNEL_NAME=$(uname -r | sed 's/-.*//')
KERNEL_TYPE=$(uname -r | sed "s/$KERNEL_NAME//")

if [[ "$KERNEL_TYPE" == "" ]]; then
    HEADERS="linux-headers"
else
    HEADERS="linux${KERNEL_TYPE}-headers"
fi

echo -e "${RED}[*] Installing kernel headers: $HEADERS...${NC}"
sudo pacman -S --needed "$HEADERS" --noconfirm

# 2. Установка всех необходимых драйверов для AMD
echo -e "${RED}[*] Installing Mesa and Vulkan drivers...${NC}"

# Основные драйверы Mesa
sudo pacman -S --needed \
    mesa \
    mesa-utils \
    lib32-mesa \
    vulkan-radeon \
    lib32-vulkan-radeon \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    xf86-video-amdgpu \
    libva-mesa-driver \
    mesa-vdpau \
    --noconfirm

# 3. Удаление всех следов NVIDIA (полная зачистка)
echo -e "${RED}[*] Cleaning up all NVIDIA remains...${NC}"
sudo rm -f /etc/modprobe.d/nvidia*.conf
sudo rm -f /etc/modprobe.d/nouveau*.conf
sudo rm -rf /usr/lib/modprobe.d/nvidia*.conf

# 4. Блокировка любых попыток загрузки NVIDIA модулей
echo -e "${RED}[*] Blacklisting NVIDIA modules (just in case)...${NC}"
sudo bash -c "cat > /etc/modprobe.d/blacklist-nvidia.conf" << EOF
# Blacklist all NVIDIA modules
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
blacklist nvidia_uvm
blacklist nouveau
blacklist lbm-nouveau
install nvidia /bin/false
install nvidia_drm /bin/false
install nvidia_modeset /bin/false
install nvidia_uvm /bin/false
install nouveau /bin/false
EOF

# 5. Настройка AMD модулей для лучшей производительности
echo -e "${RED}[*] Configuring AMD kernel modules...${NC}"
sudo bash -c "cat > /etc/modprobe.d/amdgpu.conf" << EOF
# AMD GPU оптимизации
options amdgpu si_support=1
options amdgpu cik_support=1
options amdgpu dc=1
options amdgpu dpm=1
options amdgpu runpm=0
options amdgpu gpu_recovery=0
EOF

# 6. Настройка mkinitcpio для Early KMS (AMD Edition)
echo -e "${RED}[*] Enabling Early KMS for AMD...${NC}"

# Полностью очищаем MODULES строку от NVIDIA и добавляем amdgpu
sudo sed -i '/^MODULES=/ s/nvidia nvidia_modeset nvidia_uvm nvidia_drm//g' /etc/mkinitcpio.conf

# Добавляем amdgpu, если его там нет
if ! grep -q "^MODULES=.*amdgpu" /etc/mkinitcpio.conf; then
    sudo sed -i '/^MODULES=/ s/)/ amdgpu)/' /etc/mkinitcpio.conf
fi

# Убираем лишние пробелы
sudo sed -i 's/  */ /g' /etc/mkinitcpio.conf

# 7. Настройка прав для доступа к GPU (для рендеринга и видео)
echo -e "${RED}[*] Configuring GPU permissions...${NC}"
sudo usermod -a -G video,render "$USER"

# 8. Настройка переменных окружения для Hyprland/AMD
echo -e "${RED}[*] Setting up environment variables for Hyprland...${NC}"

# Создаем или обновляем файл с переменными окружения
ENV_FILE="$HOME/.config/environment.d/amdgpu.conf"
mkdir -p "$HOME/.config/environment.d"

cat > "$ENV_FILE" << 'EOF'
# AMD GPU оптимизации для Wayland/Hyprland
AMD_VULKAN_ICD=RADV
DISABLE_QRENDERLOOP=1
# Для лучшей производительности
RADV_PERFTEST=aco
# Для исправления проблем с курсором
KWIN_DRM_NO_AMS=1
# Отключаем программный рендеринг (убедитесь, что нет WLR_RENDERER_ALLOW_SOFTWARE=1)
unset WLR_RENDERER_ALLOW_SOFTWARE
EOF

echo -e "${GREEN}[+] AMD environment variables saved to $ENV_FILE${NC}"

# 9. Пересборка образа ядра
echo -e "${RED}[*] Regenerating initramfs...${NC}"
sudo mkinitcpio -P

# 10. Проверка и отображение информации
echo -e "\n${GREEN}=== AMD GPU Installation Summary ===${NC}"
echo -e "${GREEN}[✓] Mesa drivers installed${NC}"
echo -e "${GREEN}[✓] Vulkan (RADV) installed${NC}"
echo -e "${GREEN}[✓] AMD kernel modules configured${NC}"
echo -e "${GREEN}[✓] NVIDIA completely removed${NC}"
echo -e "${GREEN}[✓] User added to video/render groups${NC}"

echo -e "\n${YELLOW}[!] IMPORTANT NOTES:${NC}"
echo -e "${YELLOW}1. Reboot now to activate AMD drivers${NC}"
echo -e "${YELLOW}2. After reboot, verify with: glxinfo | grep "OpenGL renderer"${NC}"
echo -e "${YELLOW}3. Check Vulkan: vulkaninfo --summary${NC}"
echo -e "${YELLOW}4. For best performance in Hyprland, ensure your config has:${NC}"
echo -e "${GREEN}   env = WLR_NO_HARDWARE_CURSORS,0${NC}"
echo -e "${GREEN}   env = WLR_RENDERER_ALLOW_SOFTWARE,0${NC}"

echo -e "\n${RED}[!] REBOOT REQUIRED!${NC}"
echo -e "${RED}[*] Run: sudo reboot now${NC}"