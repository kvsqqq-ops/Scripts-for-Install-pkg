#!/bin/bash

# Цвета для красоты
RED='\033[0;31m'
NC='\033[0m'

# Умное определение пути: берем папку, в которой лежит этот скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGO_SRC="$SCRIPT_DIR/logo.sh"

CONF_DIR="$HOME/.config/fastfetch"
CONF_FILE="$CONF_DIR/config.jsonc"

echo -e "${RED}[*] Configuring Xora branding for fastfetch...${NC}"

# Проверяем, существует ли логотип рядом со скриптом
if [ ! -f "$LOGO_SRC" ]; then
    echo -e "${RED}[-][ERROR] logo.sh not found at: $LOGO_SRC${NC}"
    exit 1
fi

# Создаем папку конфига
mkdir -p "$CONF_DIR"

# Делаем логотип всегда красным (ANSI wrapper)
RED_LOGO="$SCRIPT_DIR/logo.sh"

chmod +x "$RED_LOGO"

# Генерируем config.jsonc
cat > "$CONF_FILE" << EOF
{
    "\$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
    "logo": {
        "source": "$RED_LOGO",
        "type": "file",
        "padding": {
            "top": 2,
            "left": 2
        }
    },
    "display": {
        "separator": "  =>  ",
        "color": "red"
    },
    "modules": [
        "title",
        "separator",
        "os",
        "host",
        "kernel",
        "uptime",
        "packages",
        "shell",
        "display",
        "de",
        "wm",
        "terminal",
        "cpu",
        "gpu",
        "memory",
        "break",
        "colors"
    ]
}
EOF

echo -e "${RED}[+] Done! Branding applied.${NC}"
fastfetch