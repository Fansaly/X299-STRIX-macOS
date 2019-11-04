#!/bin/bash

function tolower() {
  local content="$@"

  if [[ $# -eq 0 ]]; then
    content=$(cat < /dev/stdin)
  fi

  echo "$content" | awk '{ print tolower($0) }'
}
