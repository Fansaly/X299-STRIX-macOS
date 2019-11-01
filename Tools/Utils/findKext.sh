#!/bin/bash

function findKext() {
# $1: Kext
# $2: Directory
  local kext_name="$1"
  local kext_path="${@:2}"
  local kext_dest=()
  local _dir_

  for _dir_ in ${kext_path[@]}; do
    if [[ ! -d "$_dir_" ]]; then
      continue
    fi

    kext_dest+=("$_dir_")
  done

  if [[ ${#kext_dest[@]} -eq 0 ]]; then
    return
  fi

  find "${kext_dest[@]}" -name "$kext_name" -not -path \*/PlugIns/* -not -path \*/Debug/*
}
