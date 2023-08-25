#!/usr/bin/env bash

REPO_ROOT=$1
if [ -z "$REPO_ROOT" ]; then
  echo 'REPO_ROOT is not set'
  exit 1
fi

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
done <<< "$(diff -U 100 <(asdf plugin list | sort -u) <(< $REPO_ROOT/dotfiles/.config/asdf/plugins sort -u) | sed -n '4,$p')"
