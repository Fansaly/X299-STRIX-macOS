#!/bin/bash

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

function downloadWebDriver() {
  local xml="$1"
  local file_url output_file

  file_url=$(getValue "$xml" "0.downloadURL")
  output_file=$(echo "$file_url" | perl -pe 's/.*\/(.*)/\1/')

  curl -kfSLSL "${file_url}" -o "${output_dir}/${output_file}"
}

function printMessage() {
  local title="$1"
  local content="$2"

  echo -e "$(printf "%15s" "${title}")\033[0;37m:\033[0m ${content}"
}

function printWebDriverList() {
  local xml="$1"
  local total=$2
  local count OS version size downloadURL checksum

  count=$(echo "$xml" | xpath "count(//array/dict)" 2>/dev/null)
  [[ ! "$count" =~ ^[0-9]+$ ]] && count=0
  [[ $total -gt $count ]] && total=$count

  for (( i = 0; i < $total; i++ )); do
             OS=$(getValue "$xml" "$i.OS")
        version=$(getValue "$xml" "$i.version")
    downloadURL=$(getValue "$xml" "$i.downloadURL")
           size=$(getValue "$xml" "$i.size" | awk '{printf ("%.2f", $1 / 1024 / 1024)}')" \033[0;37mMB\033[0m"
       checksum=$(getValue "$xml" "$i.checksum")

    printMessage "macOS Version" "${OS}"
    printMessage "Driver Version" "${version}"
    printMessage "Download URL" "${downloadURL}"
    printMessage "Driver Size" "${size}"
    printMessage "SHA512" "${checksum}"
    echo -ne "\n"
  done
}

function getWebDriverList() {
  local source_url=https://gfe.nvidia.com/mac-update
  local xml=$(curl -kfsSL "${source_url}")

  if [[ $? -eq 0 ]]; then
    echo "$xml" | plutil -extract updates xml1 -o - -
  fi
}


if [[ -n "${output_dir}" ]]; then
  mkdir -p "${output_dir}"
  total=1
fi

if [[ ! "$total" =~ ^[0-9]+$ && ! -d "${output_dir}" ]]; then
  help
  exit 1
fi


WebDriverList="$(getWebDriverList)"
if [[ $? -ne 0 ]]; then exit $?; fi

printWebDriverList "${WebDriverList}" $total

if [[ -d "${output_dir}" ]]; then
  downloadWebDriver "${WebDriverList}" "${output_dir}"
fi
