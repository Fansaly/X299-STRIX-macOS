#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function downloadSSDT() {
# $1: Index
# $2: SSDT name
# $3: Output directory (optional)
  local index name output_dir hotpatch_url
  index="$1"
  name="$2"
  output_dir=${UtilsDIR}/../../Downloads/Hotpatch
  hotpatch_url="https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch"

  if [[ -d "$3" ]]; then
    output_dir="$3"
  fi

  printDownloadMsg "$index" "$name" "$output_dir"
  curl -#L "${hotpatch_url}/${name}" -o "${output_dir}/${name}"

  local code=$?

  if [[ $code -ne 0 ]]; then
    printDownloadMsg "$index" "$name" "$output_dir" "ERROR" "newline"
    return $code
  fi
}
