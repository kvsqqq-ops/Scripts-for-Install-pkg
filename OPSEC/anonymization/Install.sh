echo '---=== Installing... ===---' && echo '' && \
flatpak install -y flathub com.protonvpn.www && \
yay -S --noconfirm torbrowser-launcher && \
sudo pacman -S --needed torsocks nyx dnscrypt-proxy && \
grep -qxF 'alias VPN="flatpak run com.protonvpn.www"' ~/.bashrc || echo 'alias VPN="flatpak run com.protonvpn.www"' >> ~/.bashrc && \
echo '' && echo '[+] Done!'