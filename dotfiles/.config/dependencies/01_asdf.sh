#!/usr/bin/env bash

set -e

REPO_ROOT=$1
if [ -z "$REPO_ROOT" ]; then
  echo 'REPO_ROOT is not set'
  exit 1
fi

pushd "$REPO_ROOT" > /dev/null || exit 1

# Install asdf
ASDF_VERSION=v0.11.3
if [[ ! -d $HOME/.asdf ]]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}
else
  echo 'asdf is already installed'
fi
# shellcheck disable=SC1090
. "$HOME/.asdf/asdf.sh"

# Sync asdf plugins
while read -r row; do
  if [ -z "$row" ]; then
    continue
  fi

  if [[ "$row" =~ ^\+ ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Install plugin: $plugin"
    # shellcheck disable=SC2086
    asdf plugin add $plugin
  elif [[ "$row" =~ ^\- ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Uninstall plugin: $plugin"
    asdf plugin remove "$(echo "$plugin" | cut -d' ' -f1)"
  fi
done <<< "$(diff -U 100 <(asdf plugin list | sort -u) <(< ./dotfiles/.config/asdf/plugins sort -u) | sed -n '4,$p')"

popd > /dev/null || exit 1
