#!/bin/bash
mkdir -p ~/.config/hypr/

cat > ~/.config/hypr/hyprland.conf << 'EOF'
# ==========================================
# Xora Linux - Hyprland Config
# ==========================================

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    bezier = easeOutExpo, 0.16, 1, 0.3, 1
    animation = windows, 1, 15, myBezier
    animation = windowsOut, 1, 20, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 3, default
    animation = workspaces, 1, 10, easeOutExpo, slide
    animation = specialWorkspace, 1, 10, easeOutExpo, slidevert
}

bind = SUPER, T, exec, kitty
bind = SUPER, Q, killactive,
bind = SUPER, E, exec, nemo
bind = SUPER, V, togglefloating,
bind = SUPER, R, exec, kitty yazi
#bind = SUPER, G, exec, an-anime-game-launcher
bind = SUPER, P, pseudo, # dwindle
bind = SUPER, J, layoutmsg, togglesplit # dwindle
bind = SUPER, B, exec, firefox
bind = SUPER, L, exec, Telegram
bind = SUPER, K, exec, spotify
#bind = SUPER, W, exec, bash ~/.config/rofi/scripts/wallpaper.sh
bind = SUPER, J, exec, discord
bind = SUPER, F, fullscreen
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10
bind = SUPER, S, togglespecialworkspace
bind = SUPER SHIFT, S, movetoworkspace, special

bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

input {
    kb_layout = us,ru
    kb_options = grp:alt_shift_toggle
}

windowrule = opacity 0.75 0.7, match:class .*
windowrule = opacity 0.9 0.85, match:class firefox
exec-once = hyprpaper
bind = SUPER, Y, exec, grim -g "$(slurp)" ~/Pictures/$(date +'%Y-%m-%d_%H-%M-%S').png

monitor = , 1920x1080@144, auto, 1

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgb(ff0000)
    col.inactive_border = rgb(222222)

    layout = dwindle
}

decoration {
    rounding = 15

    blur {
        enabled = true
        size = 3
        passes = 1
    }
}
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow

EOF

echo "[+] Hyprland config applied to ~/.config/hypr/hyprland.conf"