#!/usr/bin/env bash
set -euo pipefail

source_dir="$1"
target_dir="$2"

find "$source_dir" -type f -print0 | while IFS= read -r -d '' source_file; do
  relative_path="${source_file#"$source_dir"/}"
  encoded_path=""

  IFS='/' read -ra path_parts <<< "$relative_path"
  for path_part in "${path_parts[@]}"; do
    if [[ "$path_part" == .* ]]; then
      path_part="dot_${path_part#.}"
    fi

    if [[ -z "$encoded_path" ]]; then
      encoded_path="$path_part"
    else
      encoded_path="$encoded_path/$path_part"
    fi
  done

  mkdir -p "$target_dir/$(dirname "$encoded_path")"
  cp -p "$source_file" "$target_dir/$encoded_path"
done
