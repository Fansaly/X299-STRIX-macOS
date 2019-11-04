#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/download.sh"
source "${UtilsDIR}/downloadSSDT.sh"


function help() {
  echo "-c,  Kexts config file."
  echo "-d,  Download directory."
  echo "-t,  Download type, oneof Tools, Kexts, Hotpatch."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <config file>] [-d <download directory>] [-t <download type>]"
  echo "Example: $(basename $0) -c config.plist -d ~/Downloads -t Kexts"
  echo
}

while getopts c:d:t:h option; do
  case $option in
    c )
      config_plist=$OPTARG
      ;;
    d )
      downloads_dir=$OPTARG
      ;;
    t )
      downloads_type=$OPTARG
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


function downloadHotpatch() {
  config_plist="$1"
  output_dir="$2"
  type=$3

  xmlCtx=$(getValue "$config_plist" "${type}.SSDT")
  total=$(count "$xmlCtx" "//array/string")

  for (( i = 0; i < $total; i++ )); do
    ssdt=$(getSpecificValue "$xmlCtx" "$i")
    downloadSSDT "$((i+1)),$total" "$ssdt" "$output_dir"
  done
}

function getDownloads() {
  config_plist="$1"
  output_dir="$2"
  type=$3

  if [[ "$type" == "Kexts" ]]; then
    entry=${type}.Install
  else
    entry=$type
  fi

  xmlRoot=$(getValue "$config_plist" "$entry")

  total=$(count "$xmlRoot" "//array/dict/array")
  total_local=$( \
    getValue "$xmlRoot" "Local" | \
    count "//array/dict/array" \
  )
  total=$(($total - $total_local))
  index=1

  web_sites=(
    "GitHub"
    "Bitbucket"
  )

  for web_site in "${web_sites[@]}"; do
    _total=$(getValue "$xmlRoot" "$web_site" | count "//array/dict/array")

    for (( i = 0; i < $_total; i++ )); do
      kext_entry="${web_site}.${i}"
      xmlCtx=$(getValue "$xmlRoot" "$kext_entry")
      author=$(getSpecificValue "$xmlCtx" "Author")
      repo=$(getSpecificValue "$xmlCtx" "Repo")
      partial_name=$(getSpecificValue "$xmlCtx" "Name")

      download "$((index++)),$total" "$web_site" "$author" "$repo" "$output_dir" "$partial_name"
    done
  done
}

function recreateDir() {
  rm -Rf "$1" && mkdir -p "$1"
}

case ${downloads_type} in
  Tools )
    recreateDir "$downloads_dir"
    getDownloads "$config_plist" "$downloads_dir" "$downloads_type"
    ;;
  Kexts )
    recreateDir "$downloads_dir"
    getDownloads "$config_plist" "$downloads_dir" "$downloads_type"
    ;;
  Hotpatch )
    recreateDir "$downloads_dir"
    downloadHotpatch "$config_plist" "$downloads_dir" "$downloads_type"
    ;;
  * )
    help
    exit 1
    ;;
esac
