#!/usr/bin/env bash

REPO_ROOT=$1
if [ -z "$REPO_ROOT" ]; then
  echo 'REPO_ROOT is not set'
  exit 1
fi

# Install git client (GitKraken)
if ! command -v gitkraken; then
  wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
  sudo apt install -y ./gitkraken-amd64.deb
  test -f ./gitkraken-amd64.deb && rm -v ./gitkraken-amd64.deb
fi
if ! command -v gitkraken; then
  echo 'failed to install GitKraken'
  exit 1
fi
