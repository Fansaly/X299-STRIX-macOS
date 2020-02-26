#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function downloadSSDT() {
# $1: Index
# $2: Hotpatch URL
# $3: SSDT name
# $4: Output directory (optional)
  local index="$1"
  local hotpatch_url="$2"
  local name="$3"
  local output_dir=${UtilsDIR}/../../Downloads/Hotpatch

  if [[ -d "$4" ]]; then
    output_dir="$4"
  fi

  printDownloadMsg "$index" "$name" "$output_dir"
  curl -#L "${hotpatch_url}/${name}" -o "${output_dir}/${name}"

  local code=$?

  if [[ $code -ne 0 ]]; then
    printDownloadMsg "$index" "$name" "$output_dir" "ERROR" "newline"
    return $code
  fi
}
