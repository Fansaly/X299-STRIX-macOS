#!/bin/bash

efi_dir=/Volumes/EFI/EFI

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


if [[ ! -d ${efi_dir} ]]; then
  echo "${efi_dir} doesn't exist."
  exit 1
fi

if [[ ! -d ${output_dir} ]]; then
  mkdir -p "${output_dir}"
fi


rm -Rf "${output_dir}"/*
find "${efi_dir}" \( -iname "CLOVER*" -depth 1 \) -exec bash -c "cp -Rf \"\$1\" \"${output_dir}\"" _ {} \;
find "${output_dir}" -type f -exec chmod a-x {} \;


pushd "${output_dir}" > /dev/null

clover_dir=CLOVER
clover_log=Clover_Install_log.txt
zip_archives=${clover_dir}

if [[ -f "${clover_log}" ]]; then
  zip_archives+=" ${clover_log}"
fi

hostname=$(sysctl -n kern.hostname | sed -n 's/\(.*\)\..*/\1/p')
outpt_file=CLOVER_${hostname}_$(date '+%Y-%m-%d_%H-%M-%S').zip

zip -r -X -q "${outpt_file}" ${zip_archives}
echo "EFI/CLOVER zip created: ${output_dir}/${outpt_file}."

popd > /dev/null