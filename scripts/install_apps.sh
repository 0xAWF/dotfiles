#!/bin/bash

failed=()

sudo -v || exit 1
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &

is_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null |
        grep -q "install ok installed"
}

#apt
apt_install() {
    for pkg in "$@"; do
        if is_installed "$pkg"; then
            echo "[-] $pkg (already installed, skipping)"
            continue
        fi

        echo "[+] Installing APT package: $pkg"

        if ! sudo apt-get -o DPkg::Lock::Timeout=60 install -y "$pkg"; then
            echo "[!] Attempting to fix dependencies for $pkg..."

            sudo apt-get \
                -o DPkg::Lock::Timeout=60 \
                --fix-broken install -y

            if ! sudo apt-get \
                -o DPkg::Lock::Timeout=60 \
                install -y "$pkg"; then
                failed+=("$pkg (apt)")
            fi
        fi
    done
}


#flatpak 
flatpak_install() {
    for pkg in "$@"; do
        echo "[+] Installing Flatpak: $pkg"

        if ! sudo flatpak install -y flathub "$pkg"; then
            failed+=("$pkg (flatpak)")
        fi
    done
}

# snap 
snap_install() {
    for pkg in "$@"; do
        if sudo snap list "$pkg" >/dev/null 2>&1; then
            echo "[-] $pkg (already installed, skipping)"
            continue
        fi

        echo "[+] Installing Snap: $pkg"

        if ! sudo snap install "$pkg"; then
            failed+=("$pkg (snap)")
        fi
    done
}


if ! sudo apt-get -o DPkg::Lock::Timeout=60 update; then
    echo "[!] apt update failed"
    exit 1
fi

apt_install \
    vlc \
    gimp \
    fastfetch \
    htop \
    flatpak \
    gnome-software-plugin-flatpak \
    fzf \
    ripgrep \
    lazygit


sudo flatpak remote-add \
    --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak_install \
    com.discordapp.Discord \
    md.obsidian.Obsidian \
    org.signal.Signal

# Install snapd if Snap isn't available
if ! command -v snap >/dev/null 2>&1; then
    echo "[+] Installing snapd..."

    if ! sudo apt-get \
        -o DPkg::Lock::Timeout=60 \
        install -y snapd; then
        failed+=("snapd (apt)")
    fi
fi

if command -v snap >/dev/null 2>&1; then
    sudo systemctl enable --now snapd.socket 2>/dev/null || true

    # Snap applications
    snap_install \
	nvim
        bitwarden

    # Bitwarden requires this interface for secure storage
    sudo snap connect bitwarden:password-manager-service 2>/dev/null || true
else
    failed+=("snap applications (snap unavailable)")
fi

echo ""
echo "===== Install Summary ====="

if [ "${#failed[@]}" -eq 0 ]; then
    echo "All packages installed successfully!"
else
    echo "The following packages could not be installed:"

    for pkg in "${failed[@]}"; do
        echo "  - $pkg"
    done
fi

echo ""
echo "Installation complete."

