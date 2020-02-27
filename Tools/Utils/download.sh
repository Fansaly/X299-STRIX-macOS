#!/bin/bash

UtilsDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

source "${UtilsDIR}/getRemoteKextInfo.sh"
source "${UtilsDIR}/printMsg.sh"
source "${UtilsDIR}/tolower.sh"


function download() {
# $1: Index
# $2: WebSite
# $3: Author
# $4: Repo
# $5: Output directory (optional)
# $6: Partial file name to look for (optional)
  local index="$1"
  local web_site=$(tolower "$2")
  local author="$3"
  local repo="$4"
  local output_dir partial_name scrape_url

  if [[ -d "$5" ]]; then
    output_dir="$5"
    if [[ -n "$6" ]]; then
      partial_name="$6"
    fi
  elif [[ -n "$5" ]]; then
    partial_name="$5"
  fi

  scrape_url=$(getScrapeURL "$web_site" "$author" "$repo" "$partial_name")

  if [[ -z "$scrape_url" ]]; then
    printDownloadMsg "$index" "${author}/${repo}" "$output_dir" "ERROR" "newline"
    return 100 # CURL code is one of 0~96
  fi


  local url file_name
  if [[ "$web_site" = "github" ]]; then
    url="https://github.com/$scrape_url"
    file_name="${author}-${repo}.zip"

  elif [[ "$web_site" = "bitbucket" ]]; then
    url="https://bitbucket.org/$scrape_url"
    file_name=$(basename "$scrape_url")
  fi

  printDownloadMsg "$index" "$file_name" "$output_dir"
  curl -#L "$url" -o "${output_dir}/${file_name}"

  local code=$?

  if [[ $code -ne 0 ]]; then
    printDownloadMsg "$index" "$file_name" "$output_dir" "ERROR" "newline"
    return $code
  fi
}
