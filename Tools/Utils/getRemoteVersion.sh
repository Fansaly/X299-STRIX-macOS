#!/bin/bash

function getRemoteVersion() {
  local webSite=$(echo "$1" | awk '{ print tolower($0) }')
  local author="$2"
  local repo="$3"
  local tmpfile scrape version

  tmpfile="/tmp/org.${author}.download.txt"

  if [[ "$webSite" = "github" ]]; then
    curl -sL "https://github.com/${author}/${repo}/releases" -o "$tmpfile"
    scrape=$(cat "$tmpfile" | grep -o -m 1 "/.*RELEASE.*\.zip" 2>/dev/null)
    version=$(echo "$scrape" | perl -pe 's/.*\/(.*)\/.*/\1/')

  elif [[ "$webSite" = "bitbucket" ]]; then
    curl -sL "https://bitbucket.org/${author}/${repo}/downloads/" -o "$tmpfile"
    scrape=$(cat "$tmpfile" | grep -o -m 1 "${author}/${repo}/downloads/.*\.zip" 2>/dev/null | sed 's/".*//')
    version=$(echo "$scrape" | perl -pe 's/.*-(\d*-\d*)\..*/\1/')
  fi

  echo "$version"
}
