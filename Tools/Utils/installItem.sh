#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"

function getExpandAliasesStatus() {
  local expand_aliases_status result

  expand_aliases_status=$(shopt expand_aliases | awk '{ print $2 }')

  if [[ "$expand_aliases_status" == "on" ]]; then
    result=true
  fi

  echo $result
}

function installItem() {
# $1: Kext/Driver
# $2: Destination (default: /Library/Extensions)
  local item="$1"
  local item_dest="$2"
  local item_name=$(basename "$item")
  local default_kext_dest=/Library/Extensions

  if [[ $# -eq 1 ]]; then
    item_dest=$default_kext_dest;
  elif [[ ! -d "$item_dest" ]]; then
    printInstallMsg "$item_name" "$item_dest" "ERROR" "newline"
    return 1
  fi

  printInstallMsg "$item_name" "$item_dest"

  alias _rm="rm"
  alias _cp="cp"

  local need_sudo is_sudo
  if [[ "$item_dest" == "$default_kext_dest" ]]; then
    need_sudo=true
  fi

  if test "$need_sudo" && sudo -v; then
    is_sudo=true
    alias _rm="sudo rm"
    alias _cp="sudo cp"
  fi

  if [[ "$need_sudo" && ! "$is_sudo" ]]; then
    printInstallMsg "$item_name" "$item_dest" "ERROR" "newline"
    return 1
  fi

  # save default expand aliases status,
  # and enable it if it isn't enabled.
  # you can enable it directly, without consider anything.
  default_expand_aliases_enabled=$(getExpandAliasesStatus)

  if [[ ! "$default_expand_aliases_enabled" ]]; then
    shopt -s expand_aliases
  fi

  eval _rm -Rf "${item_dest}/${item_name}"
  eval _cp -Rf "$item" "$item_dest"

  local code=$?

  if [[ $code -ne 0 ]]; then
    printInstallMsg "$item_name" "$item_dest" "ERROR" "newline"
  fi

  unalias _rm _cp

  # restore expand aliases status
  # actually it has no effect
  current_expand_aliases_enabled=$(getExpandAliasesStatus)

  if [[ "$current_expand_aliases_enabled" != "$default_expand_aliases_enabled" ]]; then
    if [[ "$default_expand_aliases_enabled" ]]; then
      shopt -s expand_aliases
    else
      shopt -u expand_aliases
    fi
  fi

  return $code
}
