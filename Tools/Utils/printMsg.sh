#!/bin/bash

function printMsg() {
  local index="$1"
  local fileName="$2"
  local output_dir="$3"
  local status="$4"

  local idx total sign
  idx=$(echo "$index" | awk -F, '{ print $1 }')
  total=$(echo "$index" | awk -F, '{ print $2 }' | bc)

  if [[ $total -gt 1 ]]; then
    sign="\\033[0;32m[${idx}/${total}]\\033[0m "
  fi

  if [[ -n "$status" ]]; then
    sign="\\033[0;31m[${idx}/${total}]\\033[0m "
    status=" \\033[0;31mfailed\\033[0m"
  fi

  echo -e "${sign}\033[0;37mDownloading \033[0;35m${fileName} \033[0;37mto \033[0;96m${output_dir}\033[0m${status}"
}
