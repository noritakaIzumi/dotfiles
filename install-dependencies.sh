#!/usr/bin/env bash

set -e

REQUISITES="curl git"
echo "$REQUISITES" | tr ' ' "\n" | while read -r command; do
  if ! command -v "$command" >/dev/null; then
    echo "$command is not installed"
    exit 1
  fi
done

# Install apt dependencies
DEPENDENCIES=$(tr '\n' ' ' < dotfiles/.config/dependencies/dependencies.txt | sed -e 's/ $//g')
# shellcheck disable=SC2086
sudo apt install -y $DEPENDENCIES

# Install asdf
ASDF_VERSION=v0.11.3
if ! command -v asdf >/dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}
else
  echo 'asdf is already installed'
fi

# Sync asdf plugins
while read -r row; do
  if [ -z "$row" ]; then
    continue
  fi

  if [[ "$row" =~ ^\+ ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Install plugin: $plugin"
    asdf plugin add "$plugin"
  elif [[ "$row" =~ ^\- ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Uninstall plugin: $plugin"
    asdf plugin remove "$plugin"
  fi
done <<< "$(diff -U 100 <(asdf plugin list | sort -u) <(< ./dotfiles/.config/asdf/plugins sort -u) | sed -n '4,$p')"

# Install git client (GitKraken)
if ! command -v gitkraken; then
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo apt install -y ./gitkraken-amd64.deb
fi
if ! command -v gitkraken; then
  echo 'failed to install GitKraken'
  exit 1
fi
test -f ./gitkraken-amd64.deb && rm -v ./gitkraken-amd64.deb

# clean
sudo apt autoremove -y
sudo apt clean -y

# END
echo 'install dependencies finished'
