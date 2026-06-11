
#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}[*] Python setup for Xora Linux${NC}"
echo -e "${BLUE}=================================${NC}\n"

# Функция для проверки ошибок
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Ошибка: $1${NC}"
        exit 1
    fi
}

# 1. Установка Python и связанных пакетов
echo -e "${BLUE}[1/6] Installing Python and packages...${NC}"
sudo pacman -S --needed \
    python \
    python-pip \
    python-pipx \
    python-virtualenv \
    python-poetry \
    --noconfirm

check_error "Failed to install Python packages"

# Проверка версии
PYTHON_VERSION=$(python --version 2>&1)
PIP_VERSION=$(pip --version 2>&1)
echo -e "${GREEN}[✓] $PYTHON_VERSION${NC}"
echo -e "${GREEN}[✓] $PIP_VERSION${NC}"

# 2. Создание директории ~/.config/pip
echo -e "\n${BLUE}[2/6] Creating ~/.config/pip directory...${NC}"
mkdir -p "$HOME/.config/pip"
check_error "Failed to create ~/.config/pip"

# 3. Исправление ошибки PEP 668
echo -e "\n${BLUE}[3/6] Fixing PEP 668 error...${NC}"

# Создаем конфиг pip, который разрешает установку в систему (не рекомендуется, но убирает ошибку)
# Или лучше настроить виртуальное окружение по умолчанию

cat > "$HOME/.config/pip/pip.conf" << 'EOF'
[global]
# Отключаем предупреждение PEP 668 (НЕ РЕКОМЕНДУЕТСЯ для системных пакетов)
# Лучше использовать виртуальные окружения или pipx
break-system-packages = true

[install]
# Путь для установки пользовательских пакетов (--user по умолчанию)
user = true

[list]
# Показывать только пользовательские пакеты при pip list
user = true

[uninstall]
# Подтверждение удаления
yes = true
EOF

check_error "Failed to create pip.conf"
echo -e "${GREEN}[✓] Created ~/.config/pip/pip.conf${NC}"

# 4. Альтернативное решение - создание alias для pip с флагом --user
echo -e "\n${BLUE}[4/6] Adding pip aliases to .bashrc and .zshrc...${NC}"

# Функция для добавления алиасов
add_alias() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        if ! grep -q "alias pip=" "$config_file"; then
            cat >> "$config_file" << 'EOF'

# Python aliases for Arch Linux (fix PEP 668)
alias pip='pip install --user'
alias pip3='pip3 install --user'
alias pip-system='pip install --break-system-packages'
EOF
            echo -e "${GREEN}[✓] Aliases added to $config_file${NC}"
        else
            echo -e "${YELLOW}[!] Aliases already exist in $config_file${NC}"
        fi
    fi
}

add_alias "$HOME/.bashrc"
add_alias "$HOME/.zshrc"

# 5. Настройка pipx
echo -e "\n${BLUE}[5/6] Configuring pipx...${NC}"

# Добавляем pipx в PATH
pipx ensurepath > /dev/null 2>&1
pipx completions > /dev/null 2>&1

# Проверяем установку pipx
if command -v pipx &> /dev/null; then
    echo -e "${GREEN}[✓] pipx version: $(pipx --version)${NC}"
else
    echo -e "${RED}[!] pipx not found in PATH${NC}"
fi

# 6. Создание виртуального окружения по умолчанию (опционально)
echo -e "\n${BLUE}[6/6] Creating default virtual environment...${NC}"

if ask_yes_no() {
    local answer
    echo -e -n "${YELLOW}Создать виртуальное окружение по умолчанию в ~/venv? [y/N]: ${NC}"
    read -r answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    [[ "$answer" == "y" || "$answer" == "yes" ]]
}; then
    python -m venv "$HOME/venv"
    check_error "Failed to create virtual environment"
    
    # Добавляем активацию в .bashrc
    if ! grep -q "source ~/venv/bin/activate" "$HOME/.bashrc"; then
        cat >> "$HOME/.bashrc" << 'EOF'

# Activate default Python virtual environment
# source ~/venv/bin/activate
EOF
        echo -e "${GREEN}[✓] Virtual environment created at ~/venv${NC}"
        echo -e "${YELLOW}[!] To activate: source ~/venv/bin/activate${NC}"
    fi
else
    echo -e "${YELLOW}[*] Virtual environment creation skipped${NC}"
fi

# Итоговый отчет
echo -e "\n${BLUE}=================================${NC}"
echo -e "${GREEN}[+] Python setup completed!${NC}"
echo -e "${BLUE}=================================${NC}"

# Проверка конфигурации
echo -e "\n${GREEN}Current configuration:${NC}"
echo -e "  ${BLUE}•${NC} Python: $(python --version 2>&1)"
echo -e "  ${BLUE}•${NC} Pip: $(pip --version 2>&1 | cut -d' ' -f1-2)"
echo -e "  ${BLUE}•${NC} Pipx: $(pipx --version 2>&1 | head -n1)"
echo -e "  ${BLUE}•${NC} Config: ~/.config/pip/pip.conf"

# Показать содержимое конфига
echo -e "\n${YELLOW}Pip configuration (~/.config/pip/pip.conf):${NC}"
cat "$HOME/.config/pip/pip.conf"

# Советы по использованию
echo -e "\n${BLUE}=================================${NC}"
echo -e "${YELLOW}[!] How to use:${NC}"
echo -e "  ${GREEN}•${NC} Install package for current user: pip install <package>"
echo -e "  ${GREEN}•${NC} Install with --user flag: pip install --user <package>"
echo -e "  ${GREEN}•${NC} Install system-wide (breaks PEP 668): pip-system install <package>"
echo -e "  ${GREEN}•${NC} Install with pipx (recommended): pipx install <package>"
echo -e "  ${GREEN}•${NC} Create virtual environment: python -m venv myenv"
echo -e "  ${GREEN}•${NC} Use pip in virtual environment: myenv/bin/pip install <package>"

# Предупреждение
echo -e "\n${RED}[!] WARNING:${NC}"
echo -e "${YELLOW}  Using 'break-system-packages = true' can break system packages!${NC}"
echo -e "${YELLOW}  Always prefer virtual environments or pipx for Python packages.${NC}"

echo -e "\n${GREEN}[✓] Done! Restart your terminal or run: source ~/.bashrc${NC}\n"