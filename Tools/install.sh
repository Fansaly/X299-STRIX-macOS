#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/tolower.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/findItem.sh"
source "${UtilsDIR}/installItem.sh"
source "${UtilsDIR}/updateKextCache.sh"


function help() {
  echo "-c,  Config file."
  echo "-t,  Install type, default value kext. One of [kext, driver]"
  echo "-i,  Install kexts/drivers directory."
  echo "-d,  Download kexts/drivers directory."
  echo "-l,  Local kexts/drivers directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [Options] [Config file] [Kexts directory]"
  echo "Example: $(basename $0) -c config.plist -i /Volumes/EFI/EFI/CLOVER/kexts/Other -d ./Downloads/Kexts"
  echo
}

while getopts c:t:i:d:l:h option; do
  case $option in
    c )
      config_plist=$OPTARG
      ;;
    t )
      install_type=$OPTARG
      ;;
    i )
      install_dir=$OPTARG
      ;;
    d )
      d_dir=$OPTARG
      ;;
    l )
      l_dir=$OPTARG
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


if [[ ! -f "$config_plist" ]]; then
  echo "$config_plist doesn't exist."
  exit 1
fi

if [[ -z "$install_type" ]]; then
  install_type=kext
fi

if [[ ! "$install_type" =~ ^(kext|driver)$ ]]; then
  echo "Installation type must be one of [kext, driver]."
  exit 1
fi


function install() {
  local config_plist="$1"
  local install_type="$2"
  local install_dir="$3"
  local d_dir="$4"
  local l_dir="$5"
  local type_entry

  if [[ "$install_type" = "kext" ]]; then
    type_entry=Kexts
  elif [[ "$install_type" = "driver" ]]; then
    type_entry=Drivers
  fi

  local xmlRoot=$(getValue "$config_plist" "${type_entry}.Install")

  local entries=(
    "GitHub"
    "Bitbucket"
    "Local"
  )

  local entry total kext_entry _total
  local xmlCtx name item extension essential _install_dir_

  for entry in "${entries[@]}"; do
    total=$(getValue "$xmlRoot" "$entry" | count "//array/dict/array")

    for (( i = 0; i < $total; i++ )); do
      kext_entry="${entry}.${i}"
      _total=$(getValue "$xmlRoot" "$kext_entry.Installations" | count "//array/dict")

      for (( j = 0; j < $_total; j++ )); do
        xmlCtx=$(getValue "$xmlRoot" "$kext_entry.Installations.${j}")
        name=$(getSpecificValue "$xmlCtx" "Name")
        item=$(findItem "$name" "$d_dir" "$l_dir")
        extension=".$(tolower "${item##*.}")"
        essential=$( \
          getValue "$xmlCtx" "Essential" | \
          grep -o -i -E "true|false" | \
          tolower \
        )

        if [[ -z "$item" ]]; then continue; fi

        unset _install_dir_
        if [[ "$extension" = ".kext" ]]; then
          _install_dir_="$install_dir"
        elif [[ "$extension" = ".efi" ]]; then
          _install_dir_="${install_dir/\/kexts\/Other//drivers/UEFI}"
        fi

        installItem "$item" "$_install_dir_"

        if [[ "$extension" = ".kext" && "$essential" = "true" ]]; then
          installItem "$item"

          if [[ $? -eq 0 ]]; then
            UPDATE_KERNELCACHE=true
          fi
        fi
      done
    done
  done
}

# if [[ "${install_dir}" =~ ^/Volumes/[a-zA-Z_\-]+/EFI/CLOVER/kexts/Other$ ]]; then
#   rm -Rf "$install_dir"/*
# fi

UPDATE_KERNELCACHE=false

install "$config_plist" "$install_type" "$install_dir" "$d_dir" "$l_dir"

if [[ "$UPDATE_KERNELCACHE" = "true" ]]; then
  updateKextCache
fi
