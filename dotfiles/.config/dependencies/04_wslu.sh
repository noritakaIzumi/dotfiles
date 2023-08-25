#!/usr/bin/env bash

set -e

REPO_ROOT=$1
if [ -z "$REPO_ROOT" ]; then
  echo 'REPO_ROOT is not set'
  exit 1
fi

pushd "$REPO_ROOT" > /dev/null || exit 1

if ! command -v wslview > /dev/null; then
  sudo add-apt-repository ppa:wslutilities/wslu
  sudo apt update
  sudo apt install wslu
else
  echo 'wslu is already installed'
fi

popd > /dev/null || exit 1
