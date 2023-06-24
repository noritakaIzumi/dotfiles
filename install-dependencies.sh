#!/usr/bin/env bash

set -e

REQUISITES="curl"
echo "$REQUISITES" | tr ' ' "\n" | while read -r command; do
  if ! command -v "$command" >/dev/null; then
    echo "$command is not installed"
    exit 1
  fi
done

# Install apt dependencies
DEPENDENCIES=$(tr '\n' ' ' < dotfiles/.config/dependencies | sed -e 's/ $//g')
# shellcheck disable=SC2086
sudo apt install -y $DEPENDENCIES

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
if ! command -v gitkraken; then
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo apt install -y ./gitkraken-amd64.deb
fi
if ! command -v gitkraken; then
  echo 'failed to install GitKraken'
  exit 1
fi
rm -v ./gitkraken-amd64.deb

# clean
sudo apt autoremove -y
sudo apt clean -y

# END
echo 'install dependencies finished'
