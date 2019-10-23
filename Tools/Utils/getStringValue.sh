#!/bin/bash

function getStringValue() {
  local xml="$1"
  local entry="$2"
  local value result

  if [[ -f "$xml" ]]; then
    value=$(plutil -extract "$entry" xml1 -o - "$xml")
  else
    value=$(echo "$xml" | plutil -extract "$entry" xml1 -o - -)
  fi

  if [[ $? -eq 0 ]]; then
    result=$( \
      echo "$value" | \
      plutil -p - | \
      sed -e 's/"//g' \
    )
  fi

  echo "$result"
}
