#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/getStringValue.sh"
source "${UtilsDIR}/download.sh"
source "${UtilsDIR}/downloadSSDT.sh"


function help() {
  echo "-c,  Config file."
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

  xmlCtx=$(plutil -extract ${type}.SSDT xml1 -o - "$config_plist")
  count=$(echo "$xmlCtx" | xpath "count(//array/string)" 2>/dev/null)
  [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

  for (( i = 0; i < $count; i++ )); do
    ssdt=$(getStringValue "$xmlCtx" "$i")
    downloadSSDT "$((i+1)),$count" "$ssdt" "$output_dir"
  done
}

function getDownloads() {
  config_plist="$1"
  output_dir="$2"
  type=$3

  if [[ "${type}" == "Kexts" ]]; then
    entry=${type}.Install
  else
    entry=${type}
  fi

  xmlRoot=$(plutil -extract $entry xml1 -o - "$config_plist")

  total=$(echo "$xmlRoot" | xpath "count(//array/dict/array)" 2>/dev/null)
  total_local=$( \
    echo "$xmlRoot" | \
    plutil -extract Local xml1 -o - - | \
    xpath "count(//array/dict/array)" 2>/dev/null \
  )
  [[ ! "$total_local" =~ ^[0-9]+$ ]] && total_local=0
  total=$(($total - $total_local))
  index=1

  webSites=(
    "GitHub"
    "Bitbucket"
  )

  for webSite in "${webSites[@]}"; do
    xmlCtx=$(echo "$xmlRoot" | plutil -extract $webSite xml1 -o - -)
    count=$(echo "$xmlCtx" | xpath "count(//array/dict/array)" 2>/dev/null)
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

    for (( i = 0; i < $count; i++ )); do
      author=$(getStringValue "$xmlCtx" "${i}.Author")
      repo=$(getStringValue "$xmlCtx" "${i}.Repo")
      name=$(getStringValue "$xmlCtx" "${i}.Name")

      download "$webSite" "$((index++)),$total" "$author" "$repo" "$output_dir" "$name"
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
