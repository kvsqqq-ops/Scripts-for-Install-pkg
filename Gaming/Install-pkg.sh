echo '--- Installing gaming stack ---' && echo '' && \
sudo pacman -S --needed steam lutris gamescope && \
echo '' && \
read -p "Install AyuGram or WhatsApp? (a/w/n): " choice && \
if [ "$choice" = "a" ]; then
    yay -S --noconfirm ayugram-desktop
elif [ "$choice" = "w" ]; then
    yay -S --noconfirm whatsapp-nativefier
fi && \
echo '' && echo '[+] Done!'