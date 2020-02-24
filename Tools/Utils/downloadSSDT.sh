#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function downloadSSDT() {
# $1: Index
# $2: Hotpatch URL
# $5: SSDT name
# $4: Output directory (optional)
  local index hotpatch_url name output_dir
  index="$1"
  hotpatch_url="$2"
  name="$3"
  output_dir=${UtilsDIR}/../../Downloads/Hotpatch

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
