#!/usr/bin/env bash

set -e

REPO_ROOT=$(cd "$(dirname "$0")" && pwd)

# Create symlinks of config files
cd "${REPO_ROOT}"/dotfiles || exit
find . -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' file; do
  file=$(echo "$file" | sed 's/^.\///')
  if [[ $file = ".gitignore" ]]; then
    continue
  fi
  if [[ -L $HOME/$file ]]; then
    unlink "$HOME"/"$file"
  fi
  if [[ -f $HOME/$file || -d $HOME/$file ]]; then
    mv -v "$HOME"/"$file"{,.bk}
  fi
  ln -vnfs "$PWD"/"$file" "$HOME"
done

# Configure git
git config --global core.autocrlf input
git config --global core.editor vim
git config --global commit.gpgsign true
git config --global init.defaultbranch main
git config --global tag.forcesignannotated true
echo 'your global git config:'
cat "$HOME"/.gitconfig
GIT_CONFIG_REQUIRED="user.email user.name user.signingkey"
echo "$GIT_CONFIG_REQUIRED" | tr ' ' "\n" | while read -r config; do
  if [[ -z "$(git config --global "$config")" ]]; then
    echo "please set $config"
  fi
done

# Configure gpg pinentry program
if [[ -f '/mnt/c/Program Files (x86)/GnuPG/bin/pinentry-basic.exe' ]]; then
  cat >>~/.gnupg/gpg-agent.conf <<EOF
pinentry-program /mnt/c/Program Files (x86)/GnuPG/bin/pinentry-basic.exe
EOF
  gpgconf --kill gpg-agent
  echo 'configured gpg pinentry program'
else
  echo 'GnuPG is not installed on Windows'
fi
