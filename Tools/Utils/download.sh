#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/printMsg.sh"


function download() {
# $1: WebSite
# $2: Index
# $3: Author
# $4: Repo
# $5: Output directory (optional)
# $6: Partial file name to look for (optional)
  local web_site=$(echo "$1" | awk '{ print tolower($0) }')
  local index="$2"
  local author="$3"
  local repo="$4"

  local output_dir partial_name
  if [[ -d "$5" ]]; then
    output_dir="$5"
    if [[ -n "$6" ]]; then
      partial_name="$6"
    fi
  elif [[ -n "$5" ]]; then
    partial_name="$5"
  fi

  local tmpfile scrape

  tmpfile="/tmp/org.${author}.download.txt"

  if [[ "$web_site" = "github" ]]; then
    curl -sL "https://github.com/${author}/${repo}/releases" -o "$tmpfile"

    if [[ -n "$partial_name" ]]; then
      scrape=$(cat "$tmpfile" | grep -o -m 1 "/.*${partial_name}.*\.zip")
    else
      # Check for first non-debug *.zip match
      scrape=$(cat "$tmpfile" | grep -o "/.*\.zip" | grep -m 1 -i -v "debug")
    fi

  elif [[ "$web_site" = "bitbucket" ]]; then
    curl -sL "https://bitbucket.org/${author}/${repo}/downloads/" -o "$tmpfile"

    scrape=$( \
      cat "$tmpfile" | \
      grep -o -m 1 "${author}/${repo}/downloads/${partial_name}.*\.zip" | \
      sed 's/".*//' \
    )
  fi


  if [[ -z "$scrape" ]]; then
    printMsg "$index" "${author}/${repo}" "$output_dir" "ERROR"
    return
  fi


  local url fileName

  if [[ "$web_site" = "github" ]]; then
    url="https://github.com/$scrape"
    fileName="${author}-${repo}.zip"

  elif [[ "$web_site" = "bitbucket" ]]; then
    url="https://bitbucket.org/$scrape"
    fileName=$(basename "$scrape")
  fi

  printMsg "$index" "$fileName" "$output_dir"
  curl -#L "$url" -o "${output_dir}/${fileName}"
}
