#!/bin/bash

# Track any packages that fail to install
failed=()

# Keep sudo session alive for the duration of the script
sudo -v || exit 1
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Helper: checks if an APT package is already installed
is_installed() { dpkg -l "$1" 2>/dev/null | grep -q "^ii"; }

# Helper: installs APT packages one by one, skips if already installed, logs failures
apt_install() {
    for pkg in "$@"; do
        if is_installed "$pkg"; then
            echo "[-] $pkg (already installed, skipping)"
            continue
        fi
        if ! sudo apt-get -o DPkg::Lock::Timeout=60 install -y "$pkg"; then
            # Attempt to fix broken dependencies and retry once
            echo "[!] Attempting to fix dependencies for $pkg..."
            sudo apt-get -o DPkg::Lock::Timeout=60 --fix-broken install -y
            sudo apt-get -o DPkg::Lock::Timeout=60 install -y "$pkg" || failed+=("$pkg (apt)")
        fi
    done
}

# Helper: installs Flatpak packages one by one and logs failures
flatpak_install() {
    for pkg in "$@"; do
        flatpak install -y flathub "$pkg" || failed+=("$pkg (flatpak)")
    done
}

# Update package list before installing anything
sudo apt-get -o DPkg::Lock::Timeout=60 update

# Install APT packages (includes Flatpak and GNOME Software integration)
apt_install vlc gimp fastfetch htop flatpak gnome-software-plugin-flatpak fzf ripgrep lazygit 

# Add Flathub remote (skips if already added)
flatpak remote-add --if-not-exists flathub <https://dl.flathub.org/repo/flathub.flatpakrepo>

# Install Flatpak apps
flatpak_install com.spotify.Client com.discordapp.Discord obsidian bitwarden signal-desktop figma-linux-next

# Install snapd if not already present (e.g. on minimal Ubuntu installs)
if ! command -v snap &> /dev/null; then
    sudo apt-get -o DPkg::Lock::Timeout=60 install -y snapd || failed+=("snapd (apt)")
fi

# Install Snap apps
sudo snap install code --classic || failed+=("code (snap)")

# Print install summary
echo ""
echo "===== Install Summary ====="
if [ ${#failed[@]} -eq 0 ]; then
    echo "All packages installed successfully!"
else
    echo "The following packages could not be installed:"
    for pkg in "${failed[@]}"; do
        echo "  - $pkg"
    done
fi

echo ""
echo "Note: A system restart is required for Flatpak apps to appear in your application launcher."
