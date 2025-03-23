#!/bin/bash

# Check that exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <GITHUB_USERNAME>" >&2
    exit 1
fi

GITHUB_USERNAME=$1

# Create necessary directories and adjust permissions to avoid volume mount errors
sudo mkdir -p ${HOME}/.local ${HOME}/.config
sudo chown -R $(id -u):$(id -g) ${HOME}/.local ${HOME}/.config

if ! command -v chezmoi >/dev/null 2>&1; then
    # Install chezmoi if not available and initialize with the provided GitHub username
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
fi

EXECUTE_CHEZMOI=false
if ! test -d "$(chezmoi source-path)"; then
    # XXX: Error when running in docker container with volume mount of .config, .local respectively
    # For some reason, the error does not occur the second time or later.
    chezmoi init --apply "${GITHUB_USERNAME}" || chezmoi init --apply "${GITHUB_USERNAME}"
    EXECUTE_CHEZMOI=true
fi

if ! $EXECUTE_CHEZMOI; then
    chezmoi state reset --force
    chezmoi update
fi
