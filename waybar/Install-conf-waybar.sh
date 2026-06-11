#!/bin/bash

# Цвета
RED='\033[0;31m'
NC='\033[0m'

CONF_DIR="$HOME/.config/waybar"
mkdir -p "$CONF_DIR"

echo -e "${RED}[*] Designing Xora Waybar...${NC}"

# 1. Создаем основной конфиг (раскладка модулей)
cat > "$CONF_DIR/config" << EOF
{
    "layer": "top",
    "position": "top",
    "mod": "dock",
    "exclusive": true,
    "passthrough": false,
    "gtk-layer-shell": true,
    "height": 40,
    "modules-left": ["custom/launch_x", "hyprland/workspaces", "cpu", "memory"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["network", "pulseaudio", "clock", "tray"],

    "custom/launch_x": {
        "format": " Terminal ",
        "on-click": "kitty sh -c 'fastfetch; exec bash'",
        "tooltip": false
    },

    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "on-click": "activate",
        "format": "{icon}",
        "format-icons": {
            "1": "1",
            "2": "2",
            "3": "3",
            "4": "4",
            "default": "·"
        }
    },

    "hyprland/window": {
        "format": " {title} ",
        "separate-outputs": true
    },

    "cpu": {
        "interval": 10,
        "format": "  {usage}% ",
        "max-length": 10
    },

    "memory": {
        "interval": 30,
        "format": "  {}% ",
        "max-length": 10
    },

    "clock": {
        "format": " {:%H:%M} ",
        "tooltip-format": "{:%Y-%m-%d | %H:%M}"
    },

    "pulseaudio": {
        "format": " {icon} {volume}% ",
        "format-muted": "  ",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },

    "network": {
        "format-wifi": "  {essid} ",
        "format-ethernet": "  ",
        "format-disconnected": " ⚠ ",
        "tooltip-format": "{ifname} via {gwaddr}"
    }
}
EOF

# 2. Создаем CSS (Внешний вид)
cat > "$CONF_DIR/style.css" << EOF
* {
    border: none;
    border-radius: 0;
    font-family: "JetBrainsMono Nerd Font", "Roboto", "Helvetica", Arial, sans-serif;
    font-size: 14px;
    min-height: 0;
}

window#waybar {
    background: rgba(10, 10, 10, 0.9);
    color: #ffffff;
    border-bottom: 2px solid #ff0000; /* Твоя красная линия */
}

#custom-launch_x {
    background: #ff0000;
    color: #000000;
    font-weight: bold;
    padding: 0 10px;
    margin: 5px 10px;
    border-radius: 8px;
}

#workspaces button {
    padding: 0 5px;
    color: #ffffff;
}

#workspaces button.active {
    color: #ff0000;
    border-bottom: 2px solid #ff0000;
}

#cpu, #memory, #network, #pulseaudio, #clock {
    padding: 0 10px;
    margin: 5px 2px;
    background: #1a1a1a;
    border-radius: 8px;
    border: 1px solid #333333;
}

#cpu { color: #ff3333; }
#memory { color: #ff6666; }
#pulseaudio { color: #ffffff; }
#clock { color: #ff0000; font-weight: bold; }

#tray {
    margin: 5px 10px;
}
EOF

echo -e "${RED}[+] Waybar configured! Restart Hyprland or run 'killall waybar && waybar &' to see changes.${NC}"