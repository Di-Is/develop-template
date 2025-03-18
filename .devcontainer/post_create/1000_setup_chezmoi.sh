#!/bin/bash

# escape volume mount error
sudo mkdir -p /home/ubuntu/.local
sudo chown `id -u`:`id -g` -R /home/ubuntu/.local

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
    chezmoi init --apply ${GITHUB_USERNAME}
else
    chezmoi update
fi
