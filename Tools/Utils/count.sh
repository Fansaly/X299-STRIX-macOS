#!/bin/bash

function count() {
  local xml_content="$1"
  local entry="$2"
  local total

  if [[ $# -eq 1 ]]; then
    xml_content=$(cat < /dev/stdin)
    entry="$1"
  fi

  total=$(echo "$xml_content" | xpath "count(${entry})" 2>/dev/null)
  [[ ! "$total" =~ ^[0-9]+$ ]] && total=0

  echo $total
}
