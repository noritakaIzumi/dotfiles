#!/usr/bin/env bash

set -e

REPO_ROOT=$1
if [ -z "$REPO_ROOT" ]; then
  echo 'REPO_ROOT is not set'
  exit 1
fi

pushd "$REPO_ROOT" > /dev/null || exit 1

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
