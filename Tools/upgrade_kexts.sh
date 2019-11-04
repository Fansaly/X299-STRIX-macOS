#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/tolower.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/getRemoteKextInfo.sh"
source "${UtilsDIR}/download.sh"
source "${UtilsDIR}/findKext.sh"
source "${UtilsDIR}/installKext.sh"


function help() {
  echo "-c,  Kexts updates file."
  echo "-k,  Install kexts directory."
  echo "-d,  Download directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <file>] [-k <path/to/CLOVER/kexts>] [-d <download directory>]"
  echo "Example: $(basename $0) -c updates.plist -k /Volumes/EFI/EFI/CLOVER/kexts/Other -d ~/Downloads"
  echo
}

while getopts c:k:d:h option; do
  case $option in
    c )
      updates_plist=$OPTARG
      ;;
    k )
      install_dir=$OPTARG
      ;;
    d )
      d_kexts_dir=$OPTARG
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


if [[ ! -f "$updates_plist" ]]; then
  echo "$updates_plist doesn't exist."
  exit 1
fi


function unarchive() {
  local kext_dir="$1"
  local file_regex="$2"
  local zip_file file_path

  zip_file=$(find "$kext_dir" \( -maxdepth 1 -iname "$file_regex*\.zip" \))
  file_path=${zip_file/.zip/}

  unzip -q "$zip_file" -d "$file_path"
  rm -Rf "${file_path}/__MACOSX"
}

function getUpgrades() {
  updates_plist="$1"
  install_dir="$2"
  d_kexts_dir="$3"

  xmlRoot=$(cat "$updates_plist")

  total=$(getSpecificValue "$xmlRoot" "Total")
  index=1
  web_sites=(
    "GitHub"
    "Bitbucket"
  )

  if [[ $total -lt 1 ]]; then
    return
  fi

  for web_site in "${web_sites[@]}"; do
    _total=$(getValue "$xmlRoot" "$web_site" | count "//array/dict/array")

    for (( i = 0; i < $_total; i++ )); do
      kext_entry="${web_site}.${i}"
      xmlCtx=$(getValue "$xmlRoot" "$kext_entry")
      author=$(getSpecificValue "$xmlCtx" "Author")
      repo=$(getSpecificValue "$xmlCtx" "Repo")
      partial_name=$(getSpecificValue "$xmlCtx" "Name")
      updates=$(getSpecificValue "$xmlCtx" "Updates")

      if [[ "$updates" = "avaliable" ]]; then
        file_regex=$(getFileRegex "$web_site" "$author" "$repo" "$partial_name")
        find "$d_kexts_dir" \( -maxdepth 1 -iname "$file_regex*" \) -exec rm -Rf {} \;

        [[ $index -gt 1 ]] && echo -en "\n"
        download "$((index++)),$total" "$web_site" "$author" "$repo" "$d_kexts_dir" "$partial_name"
        unarchive "$d_kexts_dir" "$file_regex"

        __total=$(getValue "$xmlCtx" "Installations" | count "//array/dict")

        for (( j = 0; j < $__total; j++ )); do
          _xmlCtx=$(getValue "$xmlCtx" "Installations.${j}")
          name=$(getSpecificValue "$_xmlCtx" "Name")
          kext=$(findKext "$name" "$d_kexts_dir")
          essential=$( \
            getValue "$_xmlCtx" "Essential" | \
            grep -o -i -E "true|false" | \
            tolower \
          )

          if [[ -z "$kext" ]]; then continue; fi

          installKext "$kext" "$install_dir"

          if [[ "$essential" = "true" ]]; then
            installKext "$kext"
          fi
        done

        xmlCtx=$(echo "$xmlCtx" | plutil -replace "Updates" -string "upgraded" -o - -)
        xmlRoot=$( \
          echo "$xmlRoot" | \
          plutil -remove "$kext_entry" -o - - | \
          plutil -insert "$kext_entry" -xml "$xmlCtx" -o - - \
        )
      fi
    done
  done

  echo "$xmlRoot" > "$updates_plist"
}

getUpgrades "$updates_plist" "$install_dir" "$d_kexts_dir"
