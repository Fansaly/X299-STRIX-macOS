#!/bin/bash

function findItem() {
# $1: Kext/Driver
# $2: Directory
  local item_name="$1"
  local item_path="${@:2}"
  local item_dest=()
  local _dir_

  for _dir_ in ${item_path[@]}; do
    if [[ ! -d "$_dir_" ]]; then
      continue
    fi

    item_dest+=("$_dir_")
  done

  if [[ ${#item_dest[@]} -eq 0 ]]; then
    return
  fi

  find "${item_dest[@]}" -name "$item_name" -not -path \*/PlugIns/* -not -path \*/Debug/*
}
