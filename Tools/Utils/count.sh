#!/bin/bash

function count() {
  local content="$1"
  local entry="$2"
  local total

  if [[ $# -eq 1 ]]; then
    content=$(cat < /dev/stdin)
    entry="$1"
  fi

  total=$(echo "$content" | xpath "count(${entry})" 2>/dev/null)
  [[ ! "$total" =~ ^[0-9]+$ ]] && total=0

  echo $total
}
