#!/bin/bash

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


if [[ ! -f "${config_plist}" ]]; then
  echo "${config_plist} doesn't exist."
  exit 1
fi


function githubDownload() {
# $1: Author
# $2: Repo
# $3: Output directory (optional)
# $4: Partial file name to look for (optional)
  if [[ -d "$3" ]]; then
    local output_dir="$3"
    if [[ -n "$4" ]]; then
      local partial_name="$4"
    fi
  elif [[ -n "$3" ]]; then
    local partial_name="$3"
  fi
  curl --silent --location "https://github.com/$1/$2/releases" --output "/tmp/org.$1.download.txt"
  if [[ -n "$partial_name" ]]; then
    local scrape=$(grep -o -m 1 "/.*$partial_name.*\.zip" "/tmp/org.$1.download.txt")
  else
    # Check for first non-debug *.zip match
    scrape=$(grep -o "/.*\.zip" "/tmp/org.$1.download.txt" | grep -m 1 -i -v "debug")
  fi
  local fileName="$1-$2.zip"
  echo Downloading $fileName to $output_dir
  curl --progress-bar --location https://github.com/$scrape --output $output_dir/$fileName
}

function bitbucketDownload() {
# $1: Author
# $2: Repo
# $3: Output directory (optional)
# $4: Partial file name to look for (optional)
  if [[ -d "$3" ]]; then
    local output_dir="$3"
    if [[ -n "$4" ]]; then
      local partial_name="$4"
    fi
  elif [[ -n "$3" ]]; then
    local partial_name="$3"
  fi
  curl --silent --output /tmp/org.$1.download.txt --location https://bitbucket.org/$1/$2/downloads/
  scrape=$(grep -o -m 1 "$1/$2/downloads/$partial_name.*\.zip" /tmp/org.$1.download.txt | sed 's/".*//')
  fileName=$(basename $scrape)
  echo Downloading $fileName to $output_dir
  curl --progress-bar --location https://bitbucket.org/$scrape --output $output_dir/$fileName
}

function downloadSSDT() {
# $1: SSDT name
# $2: Output directory (optional)
  if [[ -d "$2" ]]; then
    local output_dir="$2"
  fi
  echo "Downloading $1 to $output_dir"
  hotpatch_repo="https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch"
  url="$hotpatch_repo/$1"
  curl --progress-bar --location "$url" --output "$output_dir/$1"
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

function downloadHotpatch() {
  config_plist="$1"
  output_dir="$2"
  type=$3

  xmlCtx=$(plutil -extract ${type}.SSDT xml1 -o - "$config_plist")
  count=$(echo "$xmlCtx" | xpath "count(//array/string)" 2>/dev/null)
  [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

  for (( i = 0; i < $count; i++ )); do
    ssdt=$(getValue "$xmlCtx" "$i")
    downloadSSDT "${ssdt}" "${output_dir}"
  done
}

function download() {
  config_plist="$1"
  output_dir="$2"
  type=$3

  options=(
    "GitHub, githubDownload"
    "Bitbucket, bitbucketDownload"
  )

  if [[ "${type}" == "Kexts" ]]; then
    entry=${type}.Install
  else
    entry=${type}
  fi

  for option in "${options[@]}"; do
    option=$(echo "${option}" | sed -e 's/[[:space:]]//g')
    _repo_=$(echo "${option}" | awk -F, '{ print $1 }')
    command=$(echo "${option}" | awk -F, '{ print $2 }')

    xmlCtx=$(plutil -extract ${entry}.${_repo_} xml1 -o - "$config_plist")
    count=$(echo "$xmlCtx" | xpath "count(//array/dict/array)" 2>/dev/null)
    [[ ! "$count" =~ ^[0-9]+$ ]] && count=0

    for (( i = 0; i < $count; i++ )); do
      author=$(getValue "$xmlCtx" "$i.Author")
      repo=$(getValue "$xmlCtx" "$i.Repo")
      name=$(getValue "$xmlCtx" "$i.Name")

      $command "$author" "$repo" "${output_dir}" "${name}"
    done
  done
}

function recreateDir() {
  rm -Rf "$1" && mkdir -p "$1"
}

case ${downloads_type} in
  Tools )
    recreateDir "${downloads_dir}"
    download "${config_plist}" "${downloads_dir}" "${downloads_type}"
    ;;
  Kexts )
    recreateDir "${downloads_dir}"
    download "${config_plist}" "${downloads_dir}" "${downloads_type}"
    ;;
  Hotpatch )
    recreateDir "${downloads_dir}"
    downloadHotpatch "${config_plist}" "${downloads_dir}" "${downloads_type}"
    ;;
  * )
    help
    exit 1
    ;;
esac
