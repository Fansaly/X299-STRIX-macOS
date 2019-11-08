#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/tolower.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/getRemoteKextInfo.sh"
source "${UtilsDIR}/download.sh"
source "${UtilsDIR}/findItem.sh"
source "${UtilsDIR}/installItem.sh"
source "${UtilsDIR}/updateKextCache.sh"


function help() {
  echo "-c,  Kexts updates file."
  echo "-d,  Download directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <file>] [-d <download directory>]"
  echo "Example: $(basename $0) -c updates.plist -d ~/Downloads"
  echo
}

while getopts c:d:h option; do
  case $option in
    c )
      updates_plist=$OPTARG
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
  d_kexts_dir="$2"

  xmlRoot=$(cat "$updates_plist")

  total=$(getSpecificValue "$xmlRoot" "Total")
  unupgraded_total=$total
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

      if [[ ! "$updates" = "avaliable" ]]; then continue; fi

      [[ $index -gt 1 ]] && echo -en "\n"

      file_regex=$(getFileRegex "$web_site" "$author" "$repo" "$partial_name")
      find "$d_kexts_dir" \( -maxdepth 1 -iname "$file_regex*" \) -exec rm -Rf {} \;

      download "$((index++)),$total" "$web_site" "$author" "$repo" "$d_kexts_dir" "$partial_name"
      unarchive "$d_kexts_dir" "$file_regex"

      STATUS=none
      __total=$(getValue "$xmlCtx" "Installations" | count "//array/dict")

      for (( j = 0; j < $__total; j++ )); do
        _xmlCtx=$(getValue "$xmlCtx" "Installations.${j}")
        name=$(getSpecificValue "$_xmlCtx" "Name")
        item=$(findItem "$name" "$d_kexts_dir")
        extension=".$(tolower "${item##*.}")"
        essential=$( \
          getValue "$_xmlCtx" "Essential" | \
          grep -o -i -E "true|false" | \
          tolower \
        )

        if [[ -z "$item" ]]; then continue; fi

        if [[ ! -d "$install_dir" ]]; then
          EFI_DIR=$("${UtilsDIR}/mount_efi.sh")
          install_dir=${EFI_DIR}/EFI/CLOVER/kexts/Other
        fi

        unset _install_dir_
        if [[ "$extension" = ".kext" ]]; then
          _install_dir_="$install_dir"
        elif [[ "$extension" = ".efi" ]]; then
          _install_dir_="${install_dir/\/kexts\/Other//drivers/UEFI}"
        fi

        installItem "$item" "$_install_dir_"
        _code_=$?

        if [[ "$extension" = ".kext" && "$essential" = "true" ]]; then
          installItem "$item"
          _code_=$?
        fi

        if [[ $_code_ -ne 0 ]]; then
          STATUS=error
        elif [[ "$essential" = "true" ]]; then
          UPDATE_KERNELCACHE=true
        fi

        if [[ "$STATUS" = "none" && $((j + 1)) -eq $__total ]]; then
          STATUS=success
        fi
      done

      if [[ ! "$STATUS" = "success" ]]; then continue; fi

      (( unupgraded_total-- ))
      xmlCtx=$(echo "$xmlCtx" | plutil -replace "Updates" -string "upgraded" -o - -)

      echo "$xmlRoot" | \
      plutil -remove "$kext_entry" -o - - | \
      plutil -insert "$kext_entry" -xml "$xmlCtx" -o - - | \
      plutil -replace "Total" -integer $unupgraded_total -o "$updates_plist" -
    done
  done
}

UPDATE_KERNELCACHE=false

getUpgrades "$updates_plist" "$d_kexts_dir"

if [[ "$UPDATE_KERNELCACHE" = "true" ]]; then
  updateKextCache
fi
