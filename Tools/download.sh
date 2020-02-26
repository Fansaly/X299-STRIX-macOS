#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/printMsg.sh"
source "${UtilsDIR}/download.sh"
source "${UtilsDIR}/downloadSSDT.sh"


function help() {
  echo "-c,  Kexts config file."
  echo "-d,  Download directory."
  echo "-t,  Download type, oneof Tools, Kexts, Hotpatch."
  echo "-p,  Another download solution, optional."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <config file>] [-d <download directory>] [-t <download type>]"
  echo "Example: $(basename $0) -c config.plist -d ~/Downloads -t Kexts"
  echo
}

while getopts c:d:t:p:h option; do
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
    p )
      plan=$OPTARG
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
  local config_plist="$1"
  local output_dir="$2"
  local type=$3
  local plan=$4

  local xmlCtx=$(getValue "$config_plist" "$type")
  local xmlSSDT=$(getValue "$xmlCtx" "SSDT")
  local total=$(count "$xmlSSDT" "//array/string")

  local author=$(getSpecificValue "$xmlCtx" "Author")
  local repo=$(getSpecificValue "$xmlCtx" "Repo")
  local path=$(getSpecificValue "$xmlCtx" "Path")

  local repo_dir="/tmp/${repo}"
  local repo_url="https://github.com/${author}/${repo}"
  local hotpatch_url="${repo_url}/raw/master/${path}"
  local hotpatch_dir="${repo_dir}/${path}"
  hotpatch_url="${hotpatch_url%/}"
  hotpatch_dir="${hotpatch_dir%/}"

  if [[ -n "$plan" ]]; then
    rm -rf "$repo_dir"
    printDownloadMsg "0,-1" "Hotpatch" "$repo_dir"
    git clone --quiet --depth 1 "$repo_url" "$repo_dir" 2>/dev/null

    if [[ $? -ne 0 ]]; then
      printDownloadMsg "0,-1" "Hotpatch" "$output_dir" "ERROR" "newline"
      return 1
    fi

    echo -en "\n"
  fi

  local ssdt index
  for (( i = 0; i < $total; i++ )); do
    ssdt=$(getSpecificValue "$xmlSSDT" "$i")
    index=$(( $i + 1 ))

    if [[ -n "$plan" ]]; then
      printCopyMsg "$index,$total" "$ssdt" "$output_dir"
      cp "${hotpatch_dir}/${ssdt}" "$output_dir"

      if [[ $? -ne 0 ]]; then
        printCopyMsg "$index,$total" "$ssdt" "$output_dir" "ERROR" "newline"
      fi
    else
      downloadSSDT "$index,$total" "$hotpatch_url" "$ssdt" "$output_dir"
    fi
  done
}

function getDownloads() {
  local config_plist="$1"
  local output_dir="$2"
  local type=$3
  local entry

  if [[ "$type" == "Kexts" ]]; then
    entry=${type}.Install
  else
    entry=$type
  fi

  local xmlRoot total total_local
  xmlRoot=$(getValue "$config_plist" "$entry")

  total=$(count "$xmlRoot" "//array/dict/array")
  total_local=$( \
    getValue "$xmlRoot" "Local" | \
    count "//array/dict/array" \
  )
  total=$(($total - $total_local))

  local web_sites=(
    "GitHub"
    "Bitbucket"
  )

  local index=1
  local web_site _total
  local kext_entry xmlCtx author repo partial_name

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
    downloadHotpatch "$config_plist" "$downloads_dir" "$downloads_type" "$plan"
    ;;
  * )
    help
    exit 1
    ;;
esac
