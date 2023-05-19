#!/usr/bin/env bash

set -e

# Install asdf
ASDF_VERSION=v0.11.3
command -v curl >/dev/null && command -v git >/dev/null &&
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch ${ASDF_VERSION}
