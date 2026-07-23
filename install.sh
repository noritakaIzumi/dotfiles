#!/bin/bash

set -e

repo_root=$(cd "$(dirname "$0")" && pwd)

sudo apt update
sudo apt install -y ansible curl git

if ! command -v chezmoi >/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
fi

export PATH="$HOME/.local/bin:$PATH"

ansible-galaxy collection install -r ansible/requirements.yml
ansible-playbook -i "$repo_root/ansible/inventory.ini" "$repo_root/ansible/playbook.yml" --ask-become-pass
