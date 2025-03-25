#!/bin/bash

sudo apt update
sudo apt install -y zsh
sudo chsh $USER -s /bin/zsh
