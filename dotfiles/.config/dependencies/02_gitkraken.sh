#!/bin/bash

set -e

repo_root=$1
if [ -z "$repo_root" ]; then
  echo 'repo_root is not set'
  exit 1
fi

pushd "$repo_root" > /dev/null || exit 1

# Install git client (GitKraken)
if ! command -v gitkraken > /dev/null; then
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo apt install -y ./gitkraken-amd64.deb
  test -f ./gitkraken-amd64.deb && rm -v ./gitkraken-amd64.deb
fi
if ! command -v gitkraken > /dev/null; then
  echo 'failed to install GitKraken'
  exit 1
fi

popd > /dev/null || exit 1
