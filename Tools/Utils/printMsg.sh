#!/bin/bash

function printMsg() {
  local index="$1"
  local type="$2"
  local msg_name="$3"
  local msg_path="$4"
  local status="$5"
  local newline="$6"

  local idx total sign
  idx=$(echo "$index" | awk -F, '{ print $1 }')
  total=$(echo "$index" | awk -F, '{ print $2 }' | bc)

  if [[ $total -gt 1 ]]; then
    sign="\\033[0;32m[${idx}/${total}]\\033[0m "

    if [[ -n "$status" ]]; then
      sign="\\033[0;31m[${idx}/${total}]\\033[0m "
    fi
  fi

  local lead_doing=(
    "Downloading"
    "Installing"
    "Copying"
  )
  local lead_failed=(
    "download"
    "install"
    "copy"
  )

  local lead
  if [[ -z "$status" ]]; then
    lead=(${lead_doing[@]})
  else
    lead=(${lead_failed[@]})
    status="\\033[0;31mFailed \\033[0;37mto\\033[0m "
  fi

  local msg_type
  if [[ "$type" = "download" ]]; then
    msg_type=${lead[0]}
  elif [[ "$type" = "install" ]]; then
    msg_type=${lead[1]}
  elif [[ "$type" = "copy" ]]; then
    msg_type=${lead[2]}
  fi

  if [[ -z "$status" ]]; then
    echo -e "${sign}\033[0;37m${msg_type} \033[0;35m${msg_name} \033[0;37mto \033[0;96m${msg_path}\033[0m"
  else
    echo -e "${sign}${status}\033[0;37m${msg_type} \033[0;35m${msg_name}\033[0m"
  fi

  if [[ -n "$newline" ]]; then
    echo -en "\n"
  fi
}

function printDownloadMsg() {
  printMsg "$1" "download" "$2" "$3" "$4" "$5"
}

function printInstallMsg() {
  printMsg "0,-1" "install" "$1" "$2" "$3" "$4"
}

function printCopyMsg() {
  printMsg "$1" "copy" "$2" "$3" "$4" "$5"
}
