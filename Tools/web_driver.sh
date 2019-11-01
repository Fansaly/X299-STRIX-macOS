#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/count.sh"
source "${UtilsDIR}/getValue.sh"


function help() {
  echo "-n,  Print the latest first \`n' of Web Driver list."
  echo "-o,  Directory used to save the latest Web Driver."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-n <number>] [-o <download directory>]"
  echo "Example: $(basename $0) -n 3"
  echo "         $(basename $0) -o ~/Downloads"
  echo
}

while getopts n:o:h option; do
  case $option in
    n )
      total=$OPTARG
      ;;
    o )
      output_dir=$OPTARG
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


function downloadWebDriver() {
  local xml="$1"
  local output_dir="$2"
  local file_url output_file

  file_url=$(getSpecificValue "$xml" "0.downloadURL")
  output_file=$(echo "$file_url" | perl -pe 's/.*\/(.*)/\1/')

  curl -kfSL "$file_url" -o "${output_dir}/${output_file}"

  if [[ $? -eq 0 ]]; then
    echo -e "\nDownload to \033[0;96m${output_dir}\033[0m\n"
  fi
}

function printMessage() {
  local lable="$1"
  local value="$2"

  echo -e "$(printf "%15s" "$lable")\033[0;37m:\033[0m $value"
}

function printWebDriverList() {
  local xml="$1"
  local total=$2
  local _total xmlCtx OS version size downloadURL checksum

  _total=$(count "$xml" "//array/dict")
  [[ $total -gt $_total ]] && total=$_total

  for (( i = 0; i < $total; i++ )); do
    xmlCtx=$(getValue "$xml" $i)

             OS=$(getSpecificValue "$xmlCtx" "OS")
        version=$(getSpecificValue "$xmlCtx" "version")
    downloadURL=$(getSpecificValue "$xmlCtx" "downloadURL")
           size=$(getSpecificValue "$xmlCtx" "size" | awk '{printf ("%.2f", $1 / 1024 / 1024)}')
       checksum=$(getSpecificValue "$xmlCtx" "checksum")

    [[ $i -gt 0 ]] && echo -en "\n"
    printMessage "macOS Version" "$OS"
    printMessage "Driver Version" "$version"
    printMessage "Download URL" "\033[0;4m${downloadURL}\033[0m"
    printMessage "Driver Size" "$size \033[0;37mMB\033[0m"
    printMessage "SHA512" "$checksum"
  done
}

function getWebDriverList() {
  local source_url=https://gfe.nvidia.com/mac-update
  local xml=$(curl -kfsSL "$source_url")

  if [[ $? -eq 0 ]]; then
    echo "$(getValue "$xml" "updates")"
  fi
}


if [[ -n "$output_dir" ]]; then
  mkdir -p "$output_dir"
  total=1
fi

if [[ ! "$total" =~ ^[0-9]+$ && ! -d "$output_dir" ]]; then
  help
  exit 1
fi


WebDriverList="$(getWebDriverList)"
if [[ $? -ne 0 ]]; then exit $?; fi

printWebDriverList "$WebDriverList" $total

if [[ -d "$output_dir" ]]; then
  echo -en "\n"
  downloadWebDriver "$WebDriverList" "$output_dir"
fi
