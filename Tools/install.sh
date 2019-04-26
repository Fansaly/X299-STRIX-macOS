#!/bin/bash

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


if [[ ! -f "${config_plist}" ]]; then
  echo "${config_plist} doesn't exist."
  exit 1
fi


function findKext() {
# $1: Kext
# $2: Directory
  find "${@:2}" -name "$1" -not -path \*/PlugIns/* -not -path \*/Debug/*
}

function installKext() {
# $1: Kext to install
# $2: Destination (default: /Library/Extensions)
  if [[ -d "$2" ]]; then local kexts_dest="$2"; fi
  kextName=$(basename $1)
  echo Installing $kextName to $kexts_dest
  rm -Rf $kexts_dest/$kextName
  cp -Rf $1 $kexts_dest
}


function getValue() {
  value=$(echo "$1" | plutil -extract "$2" xml1 -o - -)

  if [[ $? -eq 0 ]]; then
    result=$( \
      echo "${value}" | \
      plutil -p - | \
      sed -e 's/"//g' \
    )
  else
    result=
  fi

  echo "${result}"
}


function install() {
  config_plist="$1"
  install_dir="$2"
  d_kexts_dir="$3"
  l_kexts_dir="$4"

  entries=(
    "GitHub"
    "Bitbucket"
    "Local"
  )

  for entry in "${entries[@]}"; do
    xmlCtx=$(plutil -extract Kexts.Install.${entry} xml1 -o - "$config_plist")
    count=$(echo "$xmlCtx" | xpath "count(//array/dict/array)" 2>/dev/null)
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

    for (( i = 0; i < $count; i++ )); do
      _xmlCtx=$(echo "$xmlCtx" | plutil -extract $i.Installations xml1 -o - -)
      _count=$(echo "$_xmlCtx" | xpath "count(//array/dict)" 2>/dev/null)
      [[ ! "$_count" =~ ^[0-9]+$ ]] && _count=0

      for (( j = 0; j < $_count; j++ )); do
        name=$(getValue "$_xmlCtx" "$j.Name")
        kext=$(findKext "${name}" "${d_kexts_dir}" "${l_kexts_dir}")

        installKext "${kext}" "${install_dir}"
      done
    done
  done
}

# if [[ "${install_dir}" =~ ^/Volumes/[a-zA-Z_\-]+/EFI/CLOVER/kexts/Other$ ]]; then
#   rm -Rf "${install_dir}"/*
# fi

install "${config_plist}" "${install_dir}" "${d_kexts_dir}" "${l_kexts_dir}"
