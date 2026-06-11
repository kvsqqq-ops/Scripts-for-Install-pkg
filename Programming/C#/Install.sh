#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}[*] C# / .NET setup for Xora Linux${NC}"
echo -e "${BLUE}=================================${NC}\n"

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

# Функция для проверки ошибок
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Ошибка: $1${NC}"
        exit 1
    fi
}

# 1. Обновление системы
echo -e "${BLUE}[1/7] Updating system...${NC}"
sudo pacman -Syu --noconfirm
check_error "Failed to update system"

# 2. Установка .NET SDK
echo -e "\n${BLUE}[2/7] Installing .NET SDK...${NC}"

# Выбор версии .NET
echo -e "${YELLOW}Выберите версию .NET для установки:${NC}"
echo "  1) .NET 8.0 (LTS - стабильная, рекомендуется)"
echo "  2) .NET 9.0 (текущая)"
echo "  3) .NET 7.0 (устаревшая)"
echo "  4) Все версии"
echo -n -e "${BLUE}Выбор [1-4] (по умолчанию 1): ${NC}"
read -r dotnet_version

case $dotnet_version in
    2)
        DOTNET_PKG="dotnet-sdk-9.0"
        DOTNET_RUNTIME="dotnet-runtime-9.0"
        ;;
    3)
        DOTNET_PKG="dotnet-sdk-7.0"
        DOTNET_RUNTIME="dotnet-runtime-7.0"
        ;;
    4)
        DOTNET_PKG="dotnet-sdk dotnet-sdk-8.0 dotnet-sdk-9.0"
        DOTNET_RUNTIME="dotnet-runtime dotnet-runtime-8.0 dotnet-runtime-9.0"
        ;;
    *)
        DOTNET_PKG="dotnet-sdk-8.0"
        DOTNET_RUNTIME="dotnet-runtime-8.0"
        ;;
esac

sudo pacman -S --needed $DOTNET_PKG $DOTNET_RUNTIME aspnet-runtime --noconfirm
check_error "Failed to install .NET SDK"

# Проверка установки
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version 2>&1)
    echo -e "${GREEN}[✓] .NET SDK version: $DOTNET_VERSION${NC}"
else
    echo -e "${RED}[!] .NET SDK not found in PATH${NC}"
fi

# 3. Установка Mono (для кросс-платформенной разработки)
echo -e "\n${BLUE}[3/7] Installing Mono (optional)...${NC}"
if ask_yes_no "Установить Mono (для совместимости с Windows/.NET Framework)?"; then
    sudo pacman -S --needed mono mono-tools mono-msbuild --noconfirm
    check_error "Failed to install Mono"
    
    if command -v mono &> /dev/null; then
        MONO_VERSION=$(mono --version | head -n1)
        echo -e "${GREEN}[✓] $MONO_VERSION${NC}"
    fi
else
    echo -e "${YELLOW}[*] Установка Mono пропущена${NC}"
fi

# 4. Установка IDE и редакторов
echo -e "\n${BLUE}[4/7] Installing IDEs and editors...${NC}"

# Rider
if ask_yes_no "Установить JetBrains Rider (коммерческая IDE, бесплатно для студентов)?"; then
    yay -S --needed rider --noconfirm 2>/dev/null || sudo pacman -S --needed rider --noconfirm
    echo -e "${GREEN}[✓] Rider installed${NC}"
fi

# Visual Studio Code
if ask_yes_no "Установить Visual Studio Code?"; then
    yay -S --needed visual-studio-code-bin --noconfirm 2>/dev/null || sudo pacman -S --needed code --noconfirm
    echo -e "${GREEN}[✓] VS Code installed${NC}"
fi

# VSCodium (open-source версия)
if ask_yes_no "Установить VSCodium (open-source VS Code)?"; then
    yay -S --needed vscodium-bin --noconfirm 2>/dev/null || sudo pacman -S --needed vscodium --noconfirm
    echo -e "${GREEN}[✓] VSCodium installed${NC}"
fi

# 5. Установка инструментов разработки
echo -e "\n${BLUE}[5/7] Installing development tools...${NC}"

DEV_TOOLS=(
    "omnisharp-roslyn"    # C# language server
    "msbuild"             # Build system
    "nuget"              # Package manager
    "xunit"              # Testing framework
    "nunit"              # Alternative testing framework
)

for tool in "${DEV_TOOLS[@]}"; do
    if ask_yes_no "Установить $tool?"; then
        sudo pacman -S --needed "$tool" --noconfirm 2>/dev/null || yay -S "$tool" --noconfirm 2>/dev/null
        echo -e "${GREEN}[✓] $tool installed${NC}"
    fi
done

# 6. Создание конфигурации для C# (.editorconfig, omnisharp)
echo -e "\n${BLUE}[6/7] Creating configuration files...${NC}"

# Создаем глобальный .editorconfig
if ask_yes_no "Создать глобальный .editorconfig для C#?"; then
    cat > "$HOME/.editorconfig" << 'EOF'
# Global .editorconfig for C#
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.cs]
indent_size = 4
csharp_new_line_before_open_brace = none
csharp_new_line_between_query_expression_members = true

[*.json]
indent_size = 2

[*.xml]
indent_size = 2
EOF
    echo -e "${GREEN}[✓] Created ~/.editorconfig${NC}"
fi

# Создаем конфиг для OmniSharp
mkdir -p "$HOME/.omnisharp"
cat > "$HOME/.omnisharp/omnisharp.json" << 'EOF'
{
    "RoslynExtensionsOptions": {
        "EnableAnalyzersSupport": true,
        "EnableImportCompletion": true,
        "EnableDecompilationSupport": true
    },
    "FormattingOptions": {
        "EnableEditorConfigSupport": true,
        "OrganizeImports": true
    },
    "MsBuild": {
        "UseLegacySdkResolver": false
    }
}
EOF
echo -e "${GREEN}[✓] Created ~/.omnisharp/omnisharp.json${NC}"

# 7. Настройка переменных окружения
echo -e "\n${BLUE}[7/7] Setting up environment variables...${NC}"

# Добавляем переменные в .bashrc и .zshrc
add_to_shell_config() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        if ! grep -q "DOTNET_" "$config_file"; then
            cat >> "$config_file" << 'EOF'

# .NET / C# environment variables
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_PRINT_TELEMETRY_MESSAGE=false
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
export DOTNET_NOLOGO=true
export MSBUILDDISABLENODEREUSE=1

# Aliases
alias dotnet-restore='dotnet restore'
alias dotnet-build='dotnet build'
alias dotnet-run='dotnet run'
alias dotnet-test='dotnet test'
alias dotnet-publish='dotnet publish'
EOF
            echo -e "${GREEN}[✓] Added to $config_file${NC}"
        fi
    fi
}

add_to_shell_config "$HOME/.bashrc"
add_to_shell_config "$HOME/.zshrc"

# Создание шаблонного проекта
echo -e "\n${BLUE}[*] Creating sample project...${NC}"
if ask_yes_no "Создать пример консольного проекта в ~/CSharpProjects/HelloWorld?"; then
    mkdir -p "$HOME/CSharpProjects"
    cd "$HOME/CSharpProjects" || exit
    
    if command -v dotnet &> /dev/null; then
        dotnet new console -n HelloWorld -o HelloWorld
        echo -e "${GREEN}[✓] Sample project created at ~/CSharpProjects/HelloWorld${NC}"
        echo -e "${YELLOW}[!] To run: cd ~/CSharpProjects/HelloWorld && dotnet run${NC}"
    else
        echo -e "${RED}[!] dotnet not found, cannot create sample project${NC}"
    fi
fi

# Итоговый отчет
echo -e "\n${BLUE}=================================${NC}"
echo -e "${GREEN}[+] C# / .NET setup completed!${NC}"
echo -e "${BLUE}=================================${NC}"

# Проверка установленных компонентов
echo -e "\n${GREEN}Installed components:${NC}"
if command -v dotnet &> /dev/null; then
    echo -e "  ${BLUE}•${NC} .NET SDK: $(dotnet --version 2>&1)"
    echo -e "  ${BLUE}•${NC} .NET runtimes:"
    dotnet --list-runtimes 2>&1 | sed 's/^/    /'
fi

if command -v mono &> /dev/null; then
    echo -e "  ${BLUE}•${NC} Mono: $(mono --version | head -n1 | cut -d' ' -f1-5)"
fi

if command -v code &> /dev/null; then
    echo -e "  ${BLUE}•${NC} VS Code: $(code --version | head -n1)"
fi

if command -v codium &> /dev/null; then
    echo -e "  ${BLUE}•${NC} VSCodium: $(codium --version | head -n1)"
fi

if command -v rider &> /dev/null; then
    echo -e "  ${BLUE}•${NC} Rider installed"
fi

# Полезные команды
echo -e "\n${BLUE}=================================${NC}"
echo -e "${YELLOW}[!] Useful commands:${NC}"
echo -e "  ${GREEN}•${NC} Create new project: dotnet new console -n ProjectName"
echo -e "  ${GREEN}•${NC} Build project: dotnet build"
echo -e "  ${GREEN}•${NC} Run project: dotnet run"
echo -e "  ${GREEN}•${NC} Add package: dotnet add package PackageName"
echo -e "  ${GREEN}•${NC} Run tests: dotnet test"
echo -e "  ${GREEN}•${NC} Publish: dotnet publish -c Release"

# Советы
echo -e "\n${BLUE}=================================${NC}"
echo -e "${YELLOW}[!] Tips for C# development on Xora:${NC}"
echo -e "  ${GREEN}•${NC} Use OmniSharp for LSP in Neovim/VSCode"
echo -e "  ${GREEN}•${NC} .NET 8 is LTS (Long Term Support) until 2026"
echo -e "  ${GREEN}•${NC} For Windows Forms/WPF: use Mono or Wine"
echo -e "  ${GREEN}•${NC} For game development: install Unity or Godot with C#"
echo -e "  ${GREEN}•${NC} Telemetry disabled (privacy focused)"

echo -e "\n${GREEN}[✓] Done! Restart your terminal or run: source ~/.bashrc${NC}\n"

# Предложение установить дополнительные инструменты
echo -e "${BLUE}=================================${NC}"
echo -e "${YELLOW}[?] Additional tools for C# development:${NC}"

if ask_yes_no "Установить дополнительные инструменты (Rider, VS Code extensions)?"; then
    echo -e "${BLUE}[*] Installing VS Code extensions...${NC}"
    
    if command -v code &> /dev/null; then
        code --install-extension ms-dotnettools.csharp
        code --install-extension ms-dotnettools.csdevkit
        code --install-extension k--kato.docomment
        echo -e "${GREEN}[✓] VS Code extensions installed${NC}"
    fi
    
    if command -v codium &> /dev/null; then
        codium --install-extension ms-dotnettools.csharp
        echo -e "${GREEN}[✓] VSCodium extensions installed${NC}"
    fi
fi

echo -e "\n${GREEN}[✓] Complete! Happy coding in C#!${NC}\n"