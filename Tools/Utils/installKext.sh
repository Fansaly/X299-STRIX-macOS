#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function installKext() {
# $1: Kext to install
# $2: Destination (default: /Library/Extensions)
  local kext="$1"
  local kext_dest="$2"
  local kext_name=$(basename "$kext")
  local default_dest=/Library/Extensions

  if [[ $# -eq 1 ]]; then
    kext_dest=$default_dest;
  elif [[ ! -d "$kext_dest" ]]; then
    printInstallMsg "$kext_name" "$kext_dest" "ERROR"
    return 1
  fi

  printInstallMsg "$kext_name" "$kext_dest"

  if test "$kext_dest" = "$default_dest" && sudo -v; then
    sudo rm -Rf "${kext_dest}/${kext_name}"
    sudo cp -Rf "$kext" "$kext_dest"
    return $?
  fi

  rm -Rf "${kext_dest}/${kext_name}"
  cp -Rf "$kext" "$kext_dest"
}
