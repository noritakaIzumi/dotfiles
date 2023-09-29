#!/bin/bash

set -e

repo_root=$1
if [ -z "$repo_root" ]; then
  echo 'repo_root is not set'
  exit 1
fi

pushd "$repo_root" > /dev/null || exit 1

if ! command -v wslview > /dev/null; then
  sudo add-apt-repository ppa:wslutilities/wslu
  sudo apt update
  sudo apt install wslu
else
  echo 'wslu is already installed'
fi

popd > /dev/null || exit 1
