#!/bin/bash

function count() {
  local content="$1"
  local entry="$2"
  local total

  if [[ $# -eq 1 ]]; then
    content=$(cat < /dev/stdin)
    entry="$1"
  fi

  # Dealing with xpath changes in Big Sur
  # Catalina runs perl 5.18 and xpath5.18
  # Big Sur runs perl 5.28 and the newer xpath5.28
  # The problem here is that the newer xpath script has a different syntax:
  # -----------------------------------------------------------------------
  # [5.18] xpath [filename] query
  # [5.28] xpath [options] -e query [-e query...] [filename...]

  if [[ $(sw_vers -buildVersion) > "20A" ]]; then
    total=$(echo "$content" | xpath -e "count(${entry})" 2>/dev/null)
  else
    total=$(echo "$content" | xpath "count(${entry})" 2>/dev/null)
  fi
  [[ ! "$total" =~ ^[0-9]+$ ]] && total=0

  echo $total
}
