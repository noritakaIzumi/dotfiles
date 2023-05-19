#!/usr/bin/env bash

REPO_ROOT=$(cd "$(dirname "$0")" && pwd)

cd "${REPO_ROOT}"/dotfiles || exit
today=$(date '+%Y%m%d')
find . -mindepth 1 -maxdepth 1 -print0 | while IFS= read -r -d '' file; do
  file=$(echo "$file" | sed 's/^.\///')
  if [[ $file = ".gitignore" ]]; then
    continue
  fi
  if [[ -f $HOME/$file || -d $HOME/$file ]]; then
    mv -v "$HOME"/"$file"{,.bk}
  fi
  ln -vnfs "$PWD"/"$file" "$HOME"
done
