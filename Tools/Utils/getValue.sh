#!/bin/bash

function __getValue() {
  local content="$1"
  local entry="$2"
  local type="$3"
  local value result

  if [[ -f "$content" ]]; then
    value=$(plutil -extract "$entry" xml1 -o - "$content")
  else
    value=$(echo "$content" | plutil -extract "$entry" xml1 -o - -)
  fi

  if [[ $? -ne 0 ]]; then
    return
  fi

  if [[ "$type" = "default" ]]; then
    result="$value"
  else
    result=$( \
      echo "$value" | \
      plutil -p - | \
      sed -e 's/"//g' \
    )
  fi

  echo "$result"
}

function getSpecificValue() {
  echo "$(__getValue "$1" "$2")"
}

function getValue() {
  echo "$(__getValue "$1" "$2" "default")"
}
