#!/bin/bash

sudo apt update
sudo apt install -y zsh
sudo chsh $USER -s /bin/zsh

ZINIT_HOME=${HOME}/workspace/.cache/zinit
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
echo "source ${ZINIT_HOME}/zinit.zsh" >> ~/.zshrc

echo "zinit light zsh-users/zsh-completions" >> ~/.zshrc

curl -sS https://starship.rs/install.sh | sh -s -- --yes
echo 'eval "$(starship init zsh)"' >> ~/.zshrc

echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc

mkdir -p ~/.local/bin
curl https://raw.githubusercontent.com/Di-Is/develop-template/refs/heads/main/starship/pyenv -Lo ~/.local/bin/pyenv
chmod +x ~/.local/bin/pyenv

mkdir ~/.config
curl https://raw.githubusercontent.com/Di-Is/develop-template/refs/heads/main/starship/starship.toml -Lo ~/.config/starship.toml
