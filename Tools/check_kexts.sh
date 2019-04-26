#!/bin/bash

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


if [[ ! -f "${config_plist}" ]]; then
  echo "${config_plist} doesn't exist."
  exit 1
fi


function getGitHubRemoteVersion() {
  curl --silent --location "https://github.com/$1/$2/releases" --output "/tmp/org.$2.download.txt"
  scrape=$(grep -o -m 1 "/.*RELEASE.*\.zip" "/tmp/org.$2.download.txt" 2>/dev/null)
  version=$(echo "${scrape}" | perl -pe 's/.*\/(.*)\/.*/\1/')

  echo "${version}"
}

function getBitbucketRemoteVersion() {
  curl --silent --location "https://bitbucket.org/${1}/${2}/downloads/" --output "/tmp/org.$2.download.txt"
  scrape=$(grep -o -m 1 "${1}/${2}/downloads/.*\.zip" "/tmp/org.$2.download.txt" 2>/dev/null | sed 's/".*//')
  version=$(echo "${scrape}" | perl -pe 's/.*-(\d*-\d*)\..*/\1/')

  echo "${version}"
}

function findKext() {
# $1: Kext
# $2: Directory
  find "${@:2}" -name "$1" -not -path \*/PlugIns/* -not -path \*/Debug/*
}

function getValue() {
  xml="$1"
  entry="$2"

  if [[ -f "${xml}" ]]; then
    value=$(plutil -extract "${entry}" xml1 -o - "${xml}")
  else
    value=$(echo "${xml}" | plutil -extract "${entry}" xml1 -o - -)
  fi

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


function cecho() {
  _format_="$1"
  UNKNOWN="$2"
  author="$3"
  name="$4"
  local="$5"
  remote="$6"
  _uChar_S_=✓ # ✓✔✗
  _uChar_F_=✗ # ✓✔✗

  if [[ ${remote} = ${UNKNOWN} ]]; then
    name="${name} ${_uChar_F_}"
  elif [[ ${remote} != ${local} ]]; then
    name="${name} ${_uChar_S_}"
  fi

  s="$(printf "${_format_}" "$name" "$author" "$remote" "$local")"
  s=$(echo "${s}" | sed -e 's/'"${_uChar_S_}"'/\\033[0;92m'"${_uChar_S_}"'\\033[0m  /')
  s=$(echo "${s}" | sed -e 's/'"${_uChar_F_}"'/\\033[0;93m'"${_uChar_F_}"'\\033[0m  /')

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

  if [[ ${#kextsInfo[@]} -eq 0 ]]; then
    echo "No kexts."
    exit 0
  fi

  len_author=$(( ${max_len[0]} + 5 ))
  len_repo=$((   ${max_len[1]} + 5 ))
  len_name=$((   ${max_len[2]} + 5 ))
  len_local=$((  ${max_len[3]} + 5 ))
  len_remote=${len_local}
  len=$(( $len_author + $len_name + $len_local + $len_remote ))

  _format_="%-${len_name}s %-${len_author}s %-${len_remote}s %-${len_local}s"

  pad=$(printf '%*s' "$len")
  pad=${pad// /-}
  _line_=$(printf '%*.*s' 0 $len "$pad")

  echo -e "kexts \033[0;32m=> \033[0;96m${kexts_dir}\033[0m"
  echo -e "\033[0;37m${_line_}\033[0m"
  echo -e "$(printf "${_format_}" "Kexts" "Author" "Remote" "Local")"
  echo -e "\033[0;37m${_line_}\033[0m"

  for info in "${kextsInfo[@]}"; do
    arr=($(echo "${info}" | sed -e 's/|/ /g'))

    author="${arr[0]}"
    repo="${arr[1]}"
    name="${arr[2]}"
    command="${arr[3]}"
    localVersion="${arr[4]}"

    echo -ne "\033[0;37m${name} ... \033[0m"

    remoteVersion=$($command "${author}" "${repo}")
    remoteVersion=$(echo "${remoteVersion}" | sed -e 's/[[:alpha:]]*//')

    if [[ ! -n ${remoteVersion} ]]; then
      remoteVersion=${UNKNOWN}
    fi

    cecho "${_format_}" "${UNKNOWN}" "${author}" "${name}" "${localVersion}" "${remoteVersion}"
  done
}

function getKexts() {
  config_plist="$1"
  kexts_dir="$2"
  kextsInfo=()
  max_len=()

  options=(
    "GitHub, getGitHubRemoteVersion"
    "Bitbucket, getBitbucketRemoteVersion"
  )

  for option in "${options[@]}"; do
    option=$(echo "${option}" | sed -e 's/[[:space:]]//g')
    _repo_=$(echo "${option}" | awk -F, '{ print $1 }')
    command=$(echo "${option}" | awk -F, '{ print $2 }')

    xmlCtx=$(plutil -extract Kexts.Install.${_repo_} xml1 -o - "$config_plist")
    count=$(echo "$xmlCtx" | xpath "count(//array/dict/array)" 2>/dev/null)
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

    for (( i = 0; i < $count; i++ )); do
      author=$(getValue "$xmlCtx" "$i.Author")
      repo=$(getValue "$xmlCtx" "$i.Repo")

      _xmlCtx=$(echo "$xmlCtx" | plutil -extract $i.Installations xml1 -o - -)
      _count=$(echo "$_xmlCtx" | xpath "count(//array/dict)" 2>/dev/null)
      [[ ! "$_count" =~ ^[0-9]+$ ]] && _count=0

      for (( j = 0; j < $_count; j++ )); do
        name=$(getValue "$_xmlCtx" "$j.Name")
        kext=$(findKext "${name}" "${kexts_dir}")

        name=$(basename "${kext}" | sed -e 's/\.kext//')
        infoPlist=${kext}/Contents/Info.plist

        if [[ "${_repo_}" == "GitHub" ]]; then
          localVersion=$(getValue "${infoPlist}" "CFBundleVersion")
        else
          localVersion=$(echo "${infoPlist}" | perl -pe 's/.*-(\d*-\d*)\/.*/\1/')
        fi

        [[ ${#author} -gt ${max_len[0]} ]] && max_len[0]=${#author}
        [[ ${#repo}   -gt ${max_len[1]} ]] && max_len[1]=${#repo}
        [[ ${#name}   -gt ${max_len[2]} ]] && max_len[2]=${#name}
        [[ ${#localVersion} -gt ${max_len[3]} ]] && max_len[3]=${#localVersion}

        kextsInfo[$idx]+=$author
        kextsInfo[$idx]+=\|$repo
        kextsInfo[$idx]+=\|$name
        kextsInfo[$idx]+=\|$command
        kextsInfo[$idx]+=\|$localVersion

        (( idx++ ))
      done
    done
  done

  printKextsInfo ${#max_len[@]} "${max_len[@]}" "${kextsInfo[@]}"
}

getKexts "${config_plist}" "${kexts_dir}"