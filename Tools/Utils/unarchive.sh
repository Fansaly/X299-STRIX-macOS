#!/bin/bash

function help() {
  echo "-d,  Directory to unarchive all archives within."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [Options] [Archive to unarchive]"
  echo "Example: $(basename $0) ~/Downloads/Files.zip"
  echo
}

while getopts d:h option; do
  case $option in
    d )
      directory=$OPTARG
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


function findArchive() {
# $1: Zip
# $2: Directory
  find "$2" -name "$1"
}

function unarchive() {
# $1: Zip file
  local filePath=${1/.zip/}
  rm -Rf "$filePath"
  unzip -q $1 -d "$filePath"
  rm -Rf "${filePath}/__MACOSX"
}

function unarchiveAllInDirectory() {
# $1: Directory
  for zip in $(findArchive "*.zip" "$1"); do
    unarchive "$zip"
  done
}


if [[ -d "$directory" ]]; then
  unarchiveAllInDirectory "$directory"
elif [[ -e "$1" ]]; then
  unarchive "$1"
else
  help
  exit 1
fi
