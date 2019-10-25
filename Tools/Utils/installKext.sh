#!/bin/bash

function installKext() {
# $1: Kext to install
# $2: Destination (default: /Library/Extensions)
  local kext="$1"
  local kext_dest="$2"
  local kext_name=$(basename "$kext")
  local default_dest=/Library/Extensions

  if [[ ! -d "$kext_dest" ]]; then
    kext_dest=$default_dest;
  fi

  echo -e "\033[0;37mInstalling \033[0;35m${kext_name} \033[0;37mto \033[0;96m${kext_dest}\033[0m"

  if test "$kext_dest" = "$default_dest" && sudo -v; then
    sudo rm -Rf "${kext_dest}/${kext_name}"
    sudo cp -Rf "$kext" "$kext_dest"
    return
  fi

  rm -Rf "${kext_dest}/${kext_name}"
  cp -Rf "$kext" "$kext_dest"
}
