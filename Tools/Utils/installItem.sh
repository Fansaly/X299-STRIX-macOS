#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function installItem() {
# $1: Kext/Driver
# $2: Destination (default: /Library/Extensions)
  local item="$1"
  local item_dest="$2"
  local item_name=$(basename "$item")
  local default_kext_dest=/Library/Extensions

  if [[ $# -eq 1 ]]; then
    item_dest=$default_kext_dest;
  elif [[ ! -d "$item_dest" ]]; then
    printInstallMsg "$item_name" "$item_dest" "ERROR"
    return 1
  fi

  printInstallMsg "$item_name" "$item_dest"

  if test "$item_dest" = "$default_kext_dest" && sudo -v; then
    sudo rm -Rf "${item_dest}/${item_name}"
    sudo cp -Rf "$item" "$item_dest"
    return $?
  fi

  rm -Rf "${item_dest}/${item_name}"
  cp -Rf "$item" "$item_dest"
}
