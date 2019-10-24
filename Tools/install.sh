#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/getStringValue.sh"
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

  xmlRoot=$(plutil -extract Kexts.Install xml1 -o - "$config_plist")

  entries=(
    "GitHub"
    "Bitbucket"
    "Local"
  )

  for entry in "${entries[@]}"; do
    xmlCtx=$(echo "$xmlRoot" | plutil -extract $entry xml1 -o - -)
    count=$(echo "$xmlCtx" | xpath "count(//array/dict/array)" 2>/dev/null)
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

    for (( i = 0; i < $count; i++ )); do
      _xmlCtx=$(echo "$xmlCtx" | plutil -extract ${i}.Installations xml1 -o - -)
      _count=$(echo "$_xmlCtx" | xpath "count(//array/dict)" 2>/dev/null)
      [[ ! "$_count" =~ ^[0-9]+$ ]] && _count=0

      for (( j = 0; j < $_count; j++ )); do
        name=$(getStringValue "$_xmlCtx" "${j}.Name")
        kext=$(findKext "$name" "$d_kexts_dir" "$l_kexts_dir")
        essential=$( \
          echo "$_xmlCtx" | \
          plutil -extract ${j}.Essential xml1 -o - - | \
          grep -o -i -E "true|false" | \
          awk '{ print tolower($0) }' \
        )

        if [[ -z "$kext" ]]; then continue; fi

        installKext "$kext" "$install_dir"

        if [[ "$essential" = "true" ]]; then
          sudo installKext "$kext"
        fi
      done
    done
  done
}

# if [[ "${install_dir}" =~ ^/Volumes/[a-zA-Z_\-]+/EFI/CLOVER/kexts/Other$ ]]; then
#   rm -Rf "$install_dir"/*
# fi

install "$config_plist" "$install_dir" "$d_kexts_dir" "$l_kexts_dir"
