#!/bin/bash

function printMsg() {
  local index="$1"
  local action="$2"
  local text_prev="$3"
  local text_next="$4"
  local status="$5"
  local newline="$6"
  local text_lead idx total sign

  idx=$(echo "$index" | awk -F, '{ print $1 }')
  total=$(echo "$index" | awk -F, '{ print $2 }' | bc)

  if [[ $total -gt 1 ]]; then
    sign="\\033[0;32m[${idx}/${total}]\\033[0m "

    if [[ -n "$status" ]]; then
      sign="\\033[0;31m[${idx}/${total}]\\033[0m "
    fi
  fi

  if [[ -n "$status" ]]; then
    status=" \\033[0;31mFAILED\\033[0m"
  fi

  if [[ "$action" = "download" ]]; then
    text_lead=Downloading
  elif [[ "$action" = "install" ]]; then
    text_lead=Installing
  elif [[ "$action" = "copy" ]]; then
    text_lead=Copying
  fi

  echo -e "${sign}\033[0;37m${text_lead} \033[0;35m${text_prev} \033[0;37mto \033[0;96m${text_next}\033[0m${status}"

  if [[ -n "$newline" ]]; then
    echo -en "\n"
  fi
}

function printCopyMsg() {
  printMsg "$1" "copy" "$2" "$3" "$4" "$5"
}

function printDownloadMsg() {
  printMsg "$1" "download" "$2" "$3" "$4" "$5"
}

function printInstallMsg() {
  printMsg "0,-1" "install" "$1" "$2" "$3" "$4"
}
