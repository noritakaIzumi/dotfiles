#!/bin/bash

set -e

repo_root=$1
if [ -z "$repo_root" ]; then
  echo 'repo_root is not set'
  exit 1
fi

pushd "$repo_root" > /dev/null || exit 1

if [[ ! -f "$HOME/.volta/bin/volta" ]]; then
  curl https://get.volta.sh | bash -s -- --skip-setup
else
  echo 'Volta is already installed'
fi
if [[ ! -f "$HOME/.volta/bin/volta" ]]; then
  echo 'failed to install Volta'
  exit 1
fi

popd > /dev/null || exit 1
