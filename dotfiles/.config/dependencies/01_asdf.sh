#!/bin/bash

set -e

repo_root=$1
if [ -z "$repo_root" ]; then
  echo 'repo_root is not set'
  exit 1
fi

pushd "$repo_root" > /dev/null || exit 1

# Install asdf
asdf_version=v0.11.3
if ! command -v asdf >/dev/null; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${asdf_version}
else
  echo 'asdf is already installed'
fi
# shellcheck disable=SC1090
. "$HOME/.asdf/asdf.sh"

#######################################
# asdf plugin add
# Arguments:
#   Plugin name, or "plugin name and Git repository" as space-concatenated.
# Returns:
#   1 if the arguments is empty
#######################################
asdf_plugin_add() {
  local plugin_name
  local git_repo

  if [[ -z "$1" ]]; then
    return 1
  fi

  if [[ "$1" =~ ^[^\ ]+\ [^\ ]+$ ]]; then
    plugin_name=$(echo "$1" | cut -d' ' -f1)
    git_repo=$(echo "$1" | cut -d' ' -f2)
  else
    plugin_name="$1"
    git_repo=""
  fi

  if [[ -z "$git_repo" ]]; then
    asdf plugin add "$plugin_name"
  else
    asdf plugin-add "$plugin_name" "$git_repo"
  fi
}

# Sync asdf plugins
while read -r row; do
  if [ -z "$row" ]; then
    continue
  fi

  if [[ "$row" =~ ^\+ ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Install plugin: $plugin"
    asdf_plugin_add "$plugin"
  elif [[ "$row" =~ ^\- ]]; then
    plugin=$(echo "$row" | cut -b2-)
    echo "Uninstall plugin: $plugin"
    asdf plugin remove "$(echo "$plugin" | cut -d' ' -f1)"
  fi
done <<< "$(diff -U 100 <(asdf plugin list | sort -u) <(< ./dotfiles/.config/asdf/plugins sort -u) | sed -n '4,$p')"

popd > /dev/null || exit 1
