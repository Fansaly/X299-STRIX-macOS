#!/bin/bash

function installKext() {
# $1: Kext to install
# $2: Destination (default: /Library/Extensions)
  local kextName=$(basename "$1")
  local kexts_dest=/Library/Extensions

  if [[ -d "$2" ]]; then kexts_dest="$2"; fi

  echo -e "\033[0;37mInstalling \033[0;35m${kextName} \033[0;37mto \033[0;96m${kexts_dest}\033[0m"
  rm -Rf "${kexts_dest}/${kextName}"
  cp -Rf "$1" "$kexts_dest"
}
