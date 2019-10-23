#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/getStringValue.sh"
source "${UtilsDIR}/findKext.sh"
source "${UtilsDIR}/getRemoteVersion.sh"


function help() {
  echo "-c,  Config file."
  echo "-d,  Download kexts directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-c <config file>] [-d <download directory>]"
  echo "Example: $(basename $0) -c config.plist -d ~/Downloads/Kexts"
  echo
}

while getopts c:d:h option; do
  case $option in
    c )
      config_plist=$OPTARG
      ;;
    d )
      kexts_dir=$OPTARG
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


function fecho() {
  _format_="$1"
  UNKNOWN="$2"
  author="$3"
  name="$4"
  curr="$5"
  remote="$6"
  _uChar_S_=✓ # ✓✔✗
  _uChar_F_=✗ # ✓✔✗

  if [[ $remote = $UNKNOWN ]]; then
    name="$name $_uChar_F_"
  elif [[ $remote != $curr ]]; then
    name="$name $_uChar_S_"
  fi

  s="$(printf "$_format_" "$name" "$author" "$remote" "$curr")"
  s=$(echo "$s" | sed -e 's/'"$_uChar_S_"'/\\033[0;92m'"$_uChar_S_"'\\033[0m  /')
  s=$(echo "$s" | sed -e 's/'"$_uChar_F_"'/\\033[0;93m'"$_uChar_F_"'\\033[0m  /')

  echo -ne "\r${s}\n"
}

function printKextsInfo() {
  UNKNOWN="<unknown>"
  _format_=
  _line_=

  a=2
  b=$(( $1 + 1 ))
  c=$(( $b + 1 ))

  max_len=(${@:$a:$b})
  kextsInfo="${@:$c}"

  len_author=$(( ${max_len[0]} + 5 ))
  len_repo=$((   ${max_len[1]} + 5 ))
  len_name=$((   ${max_len[2]} + 5 ))
  len_curr=$((   ${max_len[3]} + 5 ))
  len_remote=${len_curr}
  len=$(( $len_author + $len_name + $len_curr + $len_remote ))

  _format_="%-${len_name}s %-${len_author}s %-${len_remote}s %-${len_curr}s"

  pad=$(printf '%*s' "$len")
  pad=${pad// /-}
  _line_=$(printf '%*.*s' 0 $len "$pad")

  echo -e "\033[0;94mkexts \033[0;37m=> \033[0;96m${kexts_dir}\033[0m"
  echo -e "\033[0;37m${_line_}\033[0m"
  echo -e "$(printf "${_format_}" "Kexts" "Author" "Remote" "Local")"
  echo -e "\033[0;37m${_line_}\033[0m"

  for info in "${kextsInfo[@]}"; do
    arr=($(echo "$info" | sed -e 's/|/ /g'))

    author="${arr[0]}"
    repo="${arr[1]}"
    name="${arr[2]}"
    curr="${arr[3]}"
    webSite="${arr[4]}"

    echo -ne "\033[0;37m${name} ... \033[0m"

    remote=$(getRemoteVersion "$webSite" "$author" "$repo")
    remote=$(echo "$remote" | sed -e 's/[[:alpha:]]*//')

    if [[ ! -n $remote ]]; then
      remote=$UNKNOWN
    fi

    fecho "$_format_" "$UNKNOWN" "$author" "$name" "$curr" "$remote"
  done
}

function getKextsInfo() {
  config_plist="$1"
  kexts_dir="$2"
  kextsInfo=()
  max_len=()

  xmlRoot=$(plutil -extract Kexts.Install xml1 -o - "$config_plist")

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

      _xmlCtx=$(echo "$xmlCtx" | plutil -extract ${i}.Installations xml1 -o - -)
      _count=$(echo "$_xmlCtx" | xpath "count(//array/dict)" 2>/dev/null)
      [[ ! "$_count" =~ ^[0-9]+$ ]] && _count=0

      for (( j = 0; j < $_count; j++ )); do
        name=$(getStringValue "$_xmlCtx" "${j}.Name")
        kext=$(findKext "$name" "$kexts_dir")

        if [[ $j -gt 0 || -z "$kext" ]]; then continue; fi

        name=$(basename "$kext" | sed -e 's/\.kext//')
        infoPlist=${kext}/Contents/Info.plist

        if [[ "$webSite" == "GitHub" ]]; then
          curr=$(getStringValue "$infoPlist" "CFBundleVersion")
        else
          curr=$(echo "$infoPlist" | perl -pe 's/.*-(\d*-\d*)\/.*/\1/')
        fi

        [[ ${max_len[0]} -lt ${#author} ]] && max_len[0]=${#author}
        [[ ${max_len[1]} -lt ${#repo}   ]] && max_len[1]=${#repo}
        [[ ${max_len[2]} -lt ${#name}   ]] && max_len[2]=${#name}
        [[ ${max_len[3]} -lt ${#curr}   ]] && max_len[3]=${#curr}

        kextsInfo[$idx]+=$author
        kextsInfo[$idx]+=\|$repo
        kextsInfo[$idx]+=\|$name
        kextsInfo[$idx]+=\|$curr
        kextsInfo[$idx]+=\|$webSite

        (( idx++ ))
      done
    done
  done

  if [[ ${#kextsInfo[@]} -eq 0 ]]; then
    echo -e "\033[0;31mNo kexts\033[0m in directory \033[0;33m${kexts_dir}.\033[0m"
  else
    printKextsInfo ${#max_len[@]} "${max_len[@]}" "${kextsInfo[@]}"
  fi
}

getKextsInfo "$config_plist" "$kexts_dir"
