#!/bin/bash

# Check that exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GITHUB_USERNAME>" >&2
    exit 1
fi

GITHUB_USERNAME=$1

# Create necessary directories and adjust permissions to avoid volume mount errors
sudo mkdir -p ${HOME}/.local
sudo mkdir -p ${HOME}/.config
sudo chown -R $(id -u):$(id -g) ${HOME}/.local
sudo chown -R $(id -u):$(id -g) ${HOME}/.config

if ! command -v chezmoi >/dev/null 2>&1; then
    # Install chezmoi if not available and initialize with the provided GitHub username
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    chezmoi init --apply "${GITHUB_USERNAME}"
else
    chezmoi state reset --force
    chezmoi update
fi
