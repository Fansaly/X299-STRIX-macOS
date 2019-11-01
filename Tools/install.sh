#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/findKext.sh"
source "${UtilsDIR}/installKext.sh"


function help() {
  echo "-c,  Config file."
  echo "-k,  Install kexts directory."
  echo "-d,  Download kexts directory."
  echo "-l,  Local kexts directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [Options] [Config file] [Kexts directory]"
  echo "Example: $(basename $0) -c config.plist -k /Volumes/EFI/EFI/CLOVER/kexts/Other -d ./Downloads/Kexts"
  echo
}

while getopts c:k:d:l:h option; do
  case $option in
    c )
      config_plist=$OPTARG
      ;;
    k )
      install_dir=$OPTARG
      ;;
    d )
      d_kexts_dir=$OPTARG
      ;;
    l )
      l_kexts_dir=$OPTARG
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


function install() {
  config_plist="$1"
  install_dir="$2"
  d_kexts_dir="$3"
  l_kexts_dir="$4"

  xmlRoot=$(getValue "$config_plist" "Kexts.Install")

  entries=(
    "GitHub"
    "Bitbucket"
    "Local"
  )

  for entry in "${entries[@]}"; do
    total=$(getValue "$xmlRoot" "$entry" | count "//array/dict/array")

    for (( i = 0; i < $total; i++ )); do
      kext_entry="${entry}.${i}"
      _total=$(getValue "$xmlRoot" "$kext_entry.Installations" | count "//array/dict")

      for (( j = 0; j < $_total; j++ )); do
        xmlCtx=$(getValue "$xmlRoot" "$kext_entry.Installations.${j}")
        name=$(getSpecificValue "$xmlCtx" "Name")
        kext=$(findKext "$name" "$d_kexts_dir" "$l_kexts_dir")
        essential=$( \
          getValue "$xmlCtx" "Essential" | \
          grep -o -i -E "true|false" | \
          awk '{ print tolower($0) }' \
        )

        if [[ -z "$kext" ]]; then continue; fi

        installKext "$kext" "$install_dir"

        if [[ "$essential" = "true" ]]; then
          installKext "$kext"
        fi
      done
    done
  done
}

# if [[ "${install_dir}" =~ ^/Volumes/[a-zA-Z_\-]+/EFI/CLOVER/kexts/Other$ ]]; then
#   rm -Rf "$install_dir"/*
# fi

install "$config_plist" "$install_dir" "$d_kexts_dir" "$l_kexts_dir"
