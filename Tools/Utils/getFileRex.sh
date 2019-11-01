#!/bin/bash

function getFileRex() {
  local web_site=$(echo "$1" | awk '{ print tolower($0) }')
  local author="$2"
  local repo="$3"
  local rex tmpfile scrape

  if [[ "$web_site" = "github" ]]; then
    rex="${author}-${repo}"

  elif [[ "$web_site" = "bitbucket" ]]; then
    tmpfile="/tmp/org.${author}.download.txt"
    curl -sL "https://bitbucket.org/${author}/${repo}/downloads/" -o "$tmpfile"
    scrape=$(cat "$tmpfile" | grep -o -m 1 "${author}/${repo}/downloads/.*\.zip" 2>/dev/null | sed 's/".*//')
    rex=$(echo "$scrape" | perl -pe 's/.*\/(.*)-(\d*-\d*)\..*/\1/')
  fi

  echo "$rex"
}
