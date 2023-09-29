#!/usr/bin/env bash

set -e

REPO_ROOT=$(cd "$(dirname "$0")" && pwd)

pushd "$REPO_ROOT" || exit 1

sudo apt update

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

# Install dependencies (custom scripts)
while read -r file; do
  echo "executing $file: start"
  # shellcheck disable=SC1090,SC2086
  . $file "$REPO_ROOT"
  echo "executing $file: end"
done <<< "$(find ./dotfiles/.config/dependencies -mindepth 1 -type f -name '*.sh' | sort)"

# clean
sudo apt autoremove -y
sudo apt clean -y

popd || exit 1

# END
echo 'install dependencies finished'
