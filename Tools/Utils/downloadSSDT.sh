#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function downloadSSDT() {
# $1: Index
# $2: SSDT name
# $3: Output directory (optional)
  local index name output_dir hotpatch_repo
  index="$1"
  name="$2"
  output_dir=${UtilsDIR}/../../Downloads/Hotpatch
  hotpatch_repo="https://github.com/RehabMan/OS-X-Clover-Laptop-Config/raw/master/hotpatch"

  if [[ -d "$3" ]]; then
    output_dir="$3"
  fi

  printMsg "$index" "$name" "$output_dir"
  curl -#L "${hotpatch_repo}/${name}" -o "${output_dir}/${name}"
}
