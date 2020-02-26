#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/getValue.sh"
source "${UtilsDIR}/findItem.sh"
source "${UtilsDIR}/getRemoteKextInfo.sh"


function help() {
  echo "-c,  Kexts config file."
  echo "-d,  Download kexts directory."
  echo "-o,  Output file that check updates."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <config file>] [-d <download directory>] [-o <file>]"
  echo "Example: $(basename $0) -c config.plist -d ~/Downloads/Kexts -o /tmp/updates.plist"
  echo
}

while getopts c:d:o:h option; do
  case $option in
    c )
      config_plist=$OPTARG
      ;;
    d )
      kexts_dir=$OPTARG
      ;;
    o )
      updates_plist=$OPTARG
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


function printKextInfo() {
  local _format_="$1"
  local UNKNOWN="$2"
  local author="$3"
  local name="$4"
  local curr="$5"
  local remote="$6"
  local _uChar_S_=✓ # ✓✔✗
  local _uChar_F_=✗ # ✓✔✗

  if [[ $remote = $UNKNOWN ]]; then
    name="$name $_uChar_F_"
  elif [[ $remote != $curr ]]; then
    name="$name $_uChar_S_"
  fi

  local s
  s="$(printf "$_format_" "$name" "$author" "$remote" "$curr")"
  s=$(echo "$s" | sed -e 's/'"$_uChar_S_"'/\\033[0;92m'"$_uChar_S_"'\\033[0m  /')
  s=$(echo "$s" | sed -e 's/'"$_uChar_F_"'/\\033[0;93m'"$_uChar_F_"'\\033[0m  /')

  echo -ne "\r${s}\n"
}

function getRemoteKextsInfo() {
  local config_plist="$1"
  local kexts_dir="$2"
  local updates_plist="$3"

  local max_len_cells=$4
  local max_len_index=4
  local max_len=(${@:($max_len_index + 1):$max_len_cells})
  local kextsInfo=(${@:($max_len_index + $max_len_cells + 1)})

  local len_author=$(( ${max_len[0]} + 5 ))
  local len_repo=$((   ${max_len[1]} + 5 ))
  local len_name=$((   ${max_len[2]} + 5 ))
  local len_curr=$((   ${max_len[3]} + 5 ))
  local len_remote=${len_curr}
  local len=$(( $len_author + $len_name + $len_curr + $len_remote ))

  local _format_="%-${len_name}s %-${len_author}s %-${len_remote}s %-${len_curr}s"

  local pad=$(printf '%*s' "$len")
  pad=${pad// /-}
  local _line_=$(printf '%*.*s' 0 $len "$pad")

  echo -e "\033[0;94mkexts \033[0;37m=> \033[0;96m${kexts_dir}\033[0m"
  echo -e "\033[0;37m${_line_}\033[0m"
  echo -e "$(printf "${_format_}" "Kexts" "Author" "Remote" "Local")"
  echo -e "\033[0;37m${_line_}\033[0m"

  local xmlRoot=$( \
    getValue "$config_plist" "Kexts.Install" | \
    plutil -remove "Local" -o - - \
  )

  local info arr web_site
  local author repo partial_name name
  local curr remote kext_entry xmlCtx
  local UNKNOWN="<unknown>"
  local total=0

  for info in ${kextsInfo[@]}; do
    arr=($(echo "$info" | sed -e 's/|/ /g'))

    web_site="${arr[0]}"
    author="${arr[1]}"
    repo="${arr[2]}"
    partial_name=$(echo "${arr[3]}" | awk -F/ '{ print $1 }')
    name="${arr[4]}"
    curr="${arr[5]}"
    kext_entry="${arr[6]}"

    echo -ne "\033[0;37m${name} ... \033[0m"

    remote=$(getRemoteVersion "$web_site" "$author" "$repo" "$partial_name")
    remote=$(echo "$remote" | sed -e 's/[[:alpha:]]*//')

    if [[ ! -n $remote ]]; then
      remote=$UNKNOWN
    fi

    if [[ $remote != $UNKNOWN && $remote != $curr ]]; then
      xmlCtx=$( \
        getValue "$xmlRoot" "$kext_entry" | \
        plutil -replace "Updates" -string "avaliable" -o - - \
      )
      xmlRoot=$( \
        echo "$xmlRoot" | \
        plutil -remove "$kext_entry" -o - - | \
        plutil -insert "$kext_entry" -xml "$xmlCtx" -o - - \
      )
      (( total++ ))
    fi

    printKextInfo "$_format_" "$UNKNOWN" "$author" "$name" "$curr" "$remote"
  done

  echo "$xmlRoot" | plutil -insert "Total" -integer $total -o "$updates_plist" -
}

function getLocalKextsInfo() {
  local config_plist="$1"
  local kexts_dir="$2"
  local updates_plist="$3"

  local xmlRoot=$(getValue "$config_plist" "Kexts.Install")

  local web_sites=(
    "GitHub"
    "Bitbucket"
  )

  local web_site total
  local kext_entry xmlCtx
  local author repo partial_name
  local kext kext_path name
  local curr info_plist
  local kextsInfo=()
  local max_len=()
  local idx=0

  for web_site in "${web_sites[@]}"; do
    total=$(getValue "$xmlRoot" "$web_site" | count "//array/dict/array")

    for (( i = 0; i < $total; i++ )); do
      kext_entry="${web_site}.${i}"
      xmlCtx=$(getValue "$xmlRoot" "$kext_entry")

      # kext main info
      author=$(getSpecificValue "$xmlCtx" "Author")
      repo=$(getSpecificValue "$xmlCtx" "Repo")
      partial_name=$(getSpecificValue "$xmlCtx" "Name")

      # the first one kext
      kext=$(getSpecificValue "$xmlCtx" "Installations.0.Name")
      kext_path=$(findItem "$kext" "$kexts_dir")
      name=$(echo "$kext" | sed -e 's/\.kext//')

      if [[ -z "$kext_path" ]]; then
        curr="<null>"
      else
        info_plist=${kext_path}/Contents/Info.plist

        if [[ "$web_site" == "GitHub" ]]; then
          curr=$(getSpecificValue "$info_plist" "CFBundleVersion")
        else
          curr=$(echo "$info_plist" | perl -pe 's/.*-(\d*-\d*)\/.*/\1/')
        fi
      fi

      # length
      [[ ${max_len[0]} -lt ${#author} ]] && max_len[0]=${#author}
      [[ ${max_len[1]} -lt ${#repo}   ]] && max_len[1]=${#repo}
      [[ ${max_len[2]} -lt ${#name}   ]] && max_len[2]=${#name}
      [[ ${max_len[3]} -lt ${#curr}   ]] && max_len[3]=${#curr}

      # to get updates
      kextsInfo[$idx]+=$web_site
      kextsInfo[$idx]+=\|$author
      kextsInfo[$idx]+=\|$repo
      kextsInfo[$idx]+=\|$partial_name/
      kextsInfo[$idx]+=\|$name
      kextsInfo[$idx]+=\|$curr
      kextsInfo[$idx]+=\|$kext_entry

      (( idx++ ))
    done
  done

  if [[ ${#kextsInfo[@]} -eq 0 ]]; then
    echo -e "\033[0;95mNo kexts \033[0;37min \033[0;96m${kexts_dir}\033[0m"
  else
    getRemoteKextsInfo \
      "$config_plist" "$kexts_dir" "$updates_plist" \
      "${#max_len[@]}" "${max_len[@]}" "${kextsInfo[@]}"
  fi
}

getLocalKextsInfo "$config_plist" "$kexts_dir" "$updates_plist"
