#!/bin/bash

efi_dir=/Volumes/EFI

function help() {
  echo "-d,  EFI directory (default: $efi_dir)."
  echo "-o,  Output directory."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-d <EFI directory>] [-o <output directory>]"
  echo "Example: $(basename $0) -o ~/Backup"
  echo
}

while getopts d:o:h option; do
  case $option in
    d )
      efi_dir=$OPTARG
      ;;
    o )
      output_dir=$OPTARG
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


if [[ ! -d $efi_dir ]]; then
  echo "$efi_dir doesn't exist."
  exit 1
fi

if [[ ! -d $output_dir ]]; then
  mkdir -p "$output_dir"
fi


efi_dir+=/EFI

rm -Rf "$output_dir"/*
find "$efi_dir" \( -iname "CLOVER*" -depth 1 \) -exec bash -c "cp -Rf \"\$1\" \"${output_dir}\"" _ {} \;
find "$output_dir" \( -type f -iname ".empty" \) -exec rm -Rf {} \;
find "$output_dir" \( -type f -not -path \*/MacOS/* \) -exec chmod a-x {} \;


pushd "$output_dir" > /dev/null

clover_dir=CLOVER
clover_log=Clover_Install_log.txt
zip_archives=$clover_dir

if [[ -f "$clover_log" ]]; then
  zip_archives+=" $clover_log"
fi

hostname=$(sysctl -n kern.hostname | sed -n 's/\(.*\)\..*/\1/p')
output_file=CLOVER_${hostname}_$(date '+%Y-%m-%d_%H-%M-%S').zip

zip -q -r -X "$output_file" $zip_archives
echo -e "CLOVER \033[38;5;135mInput\033[0;37m:  \033[0;96m${efi_dir}/CLOVER\033[0m"
echo -e "CLOVER \033[38;5;135mBackup\033[0;37m: \033[0;96m${output_dir}/${output_file}\033[0m"

popd > /dev/null
