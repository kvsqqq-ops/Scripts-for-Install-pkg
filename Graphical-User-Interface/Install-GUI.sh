#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функция для запроса подтверждения
ask_yes_no() {
    local prompt="$1"
    local answer
    
    while true; do
        echo -e -n "${YELLOW}$prompt [y/N]: ${NC}"
        read -r answer
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        case "$answer" in
            y|yes) return 0 ;;
            n|no|"") return 1 ;;
            *) echo -e "${RED}Пожалуйста, ответьте y или n${NC}" ;;
        esac
    done
}

if command -v yay &> /dev/null; then
    echo -e "${GREEN}[+] yay найден. Запускаю предварительную настройку интерфейса...${NC}"
    
    # Проверка и запуск Download-conf-hypr.sh
    if [ -f "./hypr/Download-conf-hypr.sh" ]; then
        echo -e "${BLUE}[*] Запуск Download-conf-hypr.sh...${NC}"
        bash "./hypr/Download-conf-hypr.sh"
    else
        echo -e "${RED}[!] Предупреждение: скрипт ./hypr/Download-conf-hypr.sh не найден.${NC}"
    fi

    # Копирование обоев в ~/Pictures/Wallpapers
    echo -e "${BLUE}[*] Копирование обоев в ~/Pictures/Wallpapers...${NC}"
    
    # Создаем целевую директорию
    WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
    mkdir -p "$WALLPAPER_DIR"
    
    if [ -d "./Wallpapers" ]; then
        # Копируем содержимое папки Wallpapers, включая вложенные папки
        cp -r "./Wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null
        echo -e "${GREEN}[✓] Обои скопированы в $WALLPAPER_DIR${NC}"
        
        # Выводим количество скопированных файлов
        COUNT=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \) | wc -l)
        echo -e "${GREEN}[✓] Скопировано $COUNT файлов обоев${NC}"
    else
        echo -e "${RED}[!] Предупреждение: папка ./Wallpapers не найдена.${NC}"
        echo -e "${YELLOW}[*] Создайте папку ./Wallpapers и поместите туда обои${NC}"
    fi

    # Запрос на установку caelestia-shell
    echo -e "${BLUE}[?] Установка caelestia-shell...${NC}"
    
    if ask_yes_no "Хотите установить caelestia-shell?"; then
        echo -e "${GREEN}[*] Начинаю установку caelestia-shell...${NC}"
        yay -S caelestia-shell --noconfirm
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[✓] caelestia-shell успешно установлен${NC}"
        else
            echo -e "${RED}[!] Ошибка при установке caelestia-shell${NC}"
        fi
    else
        echo -e "${YELLOW}[*] Установка caelestia-shell пропущена${NC}"
    fi

    echo -e "\n${GREEN}=== Установка завершена ===${NC}"
    echo -e "${GREEN}[✓] Обои скопированы в: $WALLPAPER_DIR${NC}"
    
    # Проверка наличия hyprpaper для автоматической настройки
    if command -v hyprpaper &> /dev/null; then
        echo -e "${BLUE}[*] Для использования обоев с hyprpaper, добавьте в ~/.config/hypr/hyprpaper.conf:${NC}"
        echo -e "${YELLOW}preload = $WALLPAPER_DIR/ваше_изображение.jpg${NC}"
        echo -e "${YELLOW}wallpaper = ,$WALLPAPER_DIR/ваше_изображение.jpg${NC}"
    fi

else
    echo -e "${RED}[-] Ошибка: команда 'yay' не найдена в системе.${NC}"
    echo -e "${YELLOW}[*] Установите yay перед запуском скрипта:${NC}"
    echo -e "${BLUE}    git clone https://aur.archlinux.org/yay.git${NC}"
    echo -e "${BLUE}    cd yay && makepkg -si${NC}"
    exit 1
fi