#!/bin/bash

# ohmyzshをインストール、セットアップ
sh -c "$(curl -L https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -p uv -p git
sudo chsh $USER -s /bin/zsh

curl https://raw.githubusercontent.com/Di-Is/develop-template/refs/heads/main/ohmyzsh/.p10k.zsh -o $HOME/.p10k.zsh
echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >>  $HOME/.zshrc
