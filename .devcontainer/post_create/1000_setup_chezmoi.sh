#!/bin/bash

# Check that exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GITHUB_USERNAME>" >&2
    exit 1
fi

GITHUB_USERNAME=$1

# Create necessary directories and adjust permissions to avoid volume mount errors
sudo mkdir -p /home/ubuntu/.local
sudo mkdir -p /home/ubuntu/.config
sudo chown $(id -u):$(id -g) -R /home/ubuntu/.local
sudo chown $(id -u):$(id -g) -R /home/ubuntu/.config

# Reset cache
chezmoi state reset --force

if ! command -v chezmoi >/dev/null 2>&1; then
    # Install chezmoi if not available and initialize with the provided GitHub username
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    chezmoi init --apply "${GITHUB_USERNAME}"
else
    # Update chezmoi if it is already installed
    chezmoi update
fi
