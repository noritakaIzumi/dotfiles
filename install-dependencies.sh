#!/usr/bin/env bash

set -e

REQUISITES="curl git"
echo "$REQUISITES" | tr ' ' "\n" | while read -r command; do
  if ! command -v "$command" >/dev/null; then
    echo 'curl is not installed'
    exit 1
  fi
done

# Install asdf
ASDF_VERSION=v0.11.3
if ! command -v asdf >/dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}
else
  echo 'asdf is already installed'
fi

# Install asdf plugins
while read -r plugin; do
  if asdf plugin list | grep -q "$plugin"; then
    echo "Plugin named $plugin already added"
    continue
  fi
  asdf plugin add "$plugin"
done <./dotfiles/.config/asdf/plugins

# Install git client (GitKraken)
wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
sudo apt install -y ./gitkraken-amd64.deb
if ! command -v gitkraken; then
  echo 'failed to install GitKraken'
  exit 1
fi
rm -v ./gitkraken-amd64.deb

# clean
sudo apt autoremove -y
sudo apt clean -y
