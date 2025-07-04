#!/bin/bash

set -e

sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo sed -i 's/^deb /&contrib non-free /' /etc/apt/sources.list || true

# Update and upgrade system
apt update && apt upgrade -y

# Enable Universe repository
add-apt-repository universe -y
apt update

# Install GNOME Desktop Environment
apt install -y ubuntu-desktop

echo "Installing NoMachine..."
wget -q https://download.nomachine.com/download/9.0/Linux/nomachine_9.0.188_11_amd64.deb -O /tmp/nomachine.deb
sudo dpkg -i /tmp/nomachine.deb || sudo apt-get install -f -y
rm /tmp/nomachine.deb
sudo sed -i 's|DefaultDesktopCommand.*|DefaultDesktopCommand "/usr/bin/gnome-session"|' /usr/NX/etc/node.cfg

# Install ZFS support
apt install -y zfsutils-linux

# Install and set ZSH as default shell
apt install -y zsh
chsh -s $(which zsh) $USER

# Install Oh My Zsh and Kali-like ZSH enhancements
apt install -y git fonts-powerline
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Optional: Powerlevel10k theme and useful plugins
apt install -y zsh-syntax-highlighting zsh-autosuggestions

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/powerlevel10k
echo 'source /usr/share/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
echo 'source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc
echo 'source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc

# Core essentials
apt install -y curl wget unzip gpg lsb-release software-properties-common apt-transport-https ca-certificates ntfs-3g

# Flatpak setup
apt install -y flatpak gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Creative tools
apt install -y gimp inkscape scribus blender
flatpak install -y flathub org.kde.krita

# IDEs and developer tools
apt install -y python3 python3-pip build-essential
flatpak install -y flathub com.jetbrains.PyCharm-Community

# Audio production tools
apt install -y ardour

# Video and media
apt install -y obs-studio vlc handbrake

# Browsers
apt install -y firefox
flatpak install -y flathub com.brave.Browser

# Archive tool
apt install -y p7zip-full

# Text editor
apt install -y notepadqq

# WineHQ installation for Wine + Winetricks (Ubuntu 24.04)
dpkg --add-architecture i386
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
apt update
apt install -y --install-recommends winehq-stable winetricks

# Bottles
flatpak install -y flathub com.usebottles.bottles

# Virtualization
apt install -y virtualbox
apt install -y build-essential linux-headers-$(uname -r)

# Gaming support
apt install -y steam

# Miscellaneous
apt install -y flameshot
flatpak install -y flathub com.spotify.Client
flatpak install -y flathub tv.plex.PlexDesktop

# Backup and cloud
flatpak install -y flathub com.google.Drive

# Bitwarden
flatpak install -y flathub com.bitwarden.desktop

# Privacy and telemetry removals
systemctl disable apport.service --now || true
systemctl disable whoopsie.service --now || true
sed -i 's/ENABLED=1/ENABLED=0/' /etc/default/apport || true
apt purge -y apport whoopsie ubuntu-report popularity-contest geoip-database geoclue-2.0 || true

# Disable MOTD news
chmod -x /etc/update-motd.d/10-help-text || true
chmod -x /etc/update-motd.d/50-motd-news || true
chmod -x /etc/update-motd.d/80-livepatch || true

# Optional: Disable Snap auto-refresh
mkdir -p /etc/systemd/system/snapd.service.d
cat <<EOF > /etc/systemd/system/snapd.service.d/override.conf
[Service]
Environment=SNAPD_DEBUG=1
EOF
systemctl daemon-reexec || true

# Clean up
apt autoremove -y

# Done
printf "\n\nInstallation and setup complete! Please reboot.\n"
