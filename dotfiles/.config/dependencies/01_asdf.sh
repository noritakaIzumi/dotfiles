#!/bin/bash

set -e

repo_root=$1
if [ -z "$repo_root" ]; then
  echo 'repo_root is not set'
  exit 1
fi

pushd "$repo_root" > /dev/null || exit 1

# Install asdf
asdf_version=v0.18.0
if ! command -v asdf >/dev/null; then
  asdf_tar_filename="asdf-${asdf_version}-linux-amd64.tar.gz"
  asdf_download_url="https://github.com/asdf-vm/asdf/releases/download/${asdf_version}/${asdf_tar_filename}"
  wget -q $asdf_download_url && tar -xzvf ${asdf_tar_filename} && rm -v ${asdf_tar_filename}
  mv -v asdf "$HOME/.local/bin"
else
  echo 'asdf is already installed'
fi

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
    asdf plugin add "$plugin_name" "$git_repo"
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
