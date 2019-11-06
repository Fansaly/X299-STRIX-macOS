#!/bin/bash

function updateKextCache() {
  echo -e "\n\033[38;5;90;48;5;248m Rebuild system kext caches ... \033[0m"
  sudo kextcache -i /
}
