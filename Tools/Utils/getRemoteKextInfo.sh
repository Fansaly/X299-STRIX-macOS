#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/tolower.sh"


function getRemoteKextInfo() {
  local type=$(tolower "$1")
  local web_site=$(tolower "$2")
  local author="$3"
  local repo="$4"
  local partial_name

  if [[ -n "$5" ]]; then
    partial_name="$5"
  fi

  local result tmpfile
  local scrape_url version regex

  tmpfile="/tmp/org.${author}.download.txt"

  if [[ "$web_site" = "github" ]]; then
    if [[ "$type" = "regex" ]]; then
      result="${author}-${repo}"
    else
      curl -sL "https://github.com/${author}/${repo}/releases" -o "$tmpfile"
      if [[ -n "$partial_name" ]]; then
        scrape_url=$( \
          cat "$tmpfile" | \
          grep -o -m 1 "/.*${partial_name}.*\.zip" 2>/dev/null \
        )
      else
        # Check for first non-debug *.zip match
        scrape_url=$( \
          cat "$tmpfile" | \
          grep -o "/.*\.zip" 2>/dev/null | \
          grep -m 1 -i -v "debug" 2>/dev/null \
        )
      fi

      version=$(echo "$scrape_url" | perl -pe 's/.*\/(.*)\/.*/\1/')

      if [[ "$type" = "url" ]]; then
        result="$scrape_url"
      else
        result="$version"
      fi
    fi

  elif [[ "$web_site" = "bitbucket" ]]; then
    curl -sL "https://bitbucket.org/${author}/${repo}/downloads/" -o "$tmpfile"
    scrape_url=$( \
      cat "$tmpfile" | \
      grep -o -m 1 "${author}/${repo}/downloads/${partial_name}.*\.zip" 2>/dev/null | \
      sed 's/".*//' \
    )
    version=$(echo "$scrape_url" | perl -pe 's/.*-(\d*-\d*)\..*/\1/')
    regex=$(echo "$scrape" | perl -pe 's/.*\/(.*)-(\d*-\d*)\..*/\1/')

    if [[ "$type" = "url" ]]; then
      result="$scrape_url"
    elif [[ "$type" = "version" ]]; then
      result="$version"
    else
      result="$regex"
    fi
  fi

  echo "$result"
}

# $1: WebSite
# $2: Author
# $3: Repo
# $4: Partial file name to look for (optional)
function getScrapeURL() {
  getRemoteKextInfo "url" "$1" "$2" "$3" "$4"
}

function getRemoteVersion() {
  getRemoteKextInfo "version" "$1" "$2" "$3" "$4"
}

function getFileRegex() {
  getRemoteKextInfo "regex" "$1" "$2" "$3" "$4"
}
