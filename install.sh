#!/bin/bash

set -e

repo_root=$(cd "$(dirname "$0")" && pwd)

pushd "$repo_root" > /dev/null || exit 1

# Install dependencies
. ./install_dependencies.sh

# Create symlinks of config files
pushd ./dotfiles > /dev/null || exit
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
git config --global gpg.program gpg
git config --global init.defaultbranch main
git config --global tag.forcesignannotated true
git config --global alias.root 'rev-parse --show-toplevel'
echo 'your global git config:'
cat "$HOME"/.gitconfig
git_config_required="user.email user.name user.signingkey"
echo "$git_config_required" | tr ' ' "\n" | while read -r config; do
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

popd > /dev/null || exit
