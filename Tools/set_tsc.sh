#!/bin/bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UtilsDIR=${DIR}/Utils

source "${UtilsDIR}/getValue.sh"


function help() {
  echo "-k,  TSCAdjustReset.kext directory."
  echo "-p,  Print CPU Info."
  echo "-h,  Show this help message."
  echo
  echo "Usage: $(basename $0) [-k <kext directory>] [-p]"
  echo "Example: $(basename $0) -p"
  echo
}

while getopts k:ph option; do
  case $option in
    k )
      TSCAdjustResetKextDIR=$OPTARG
      ;;
    p )
      display=1
      ;;
    h )
      help
      exit 0
      ;;
  esac
done

shift $((OPTIND-1))


TSCAdjustResetInfoPlist=${TSCAdjustResetKextDIR}/Contents/Info.plist

if [[ ! -f "$TSCAdjustResetInfoPlist" ]]; then
  echo "The TSCAdjustReset Info.plist file doesn't exist."
  exit 1
fi


function getCPUKind() {
  local PROCESSOR CPUKind

  PROCESSOR=$(sysctl -n machdep.cpu.brand_string)

  PROCESSOR=$(printf "$PROCESSOR" | perl -pe 's/\s+cpu//i')
  PROCESSOR=$(printf "$PROCESSOR" | perl -pe 's/\(R\)//g and s/\(TM\)//ig')

  CPUKind=$(printf "$PROCESSOR" | perl -pe 's/\s+@.*//')

  echo "$CPUKind"
}

threads=$(sysctl -n hw.ncpu)
IOCPUNumber=$(($threads - 1))

entry=IOKitPersonalities.TSCAdjustReset.IOPropertyMatch.IOCPUNumber
value=$(getSpecificValue "$TSCAdjustResetInfoPlist" "$entry")

if [[ $value -ne $IOCPUNumber ]]; then
  plutil -replace "$entry" -integer $IOCPUNumber "$TSCAdjustResetInfoPlist"
fi


if [[ $display ]]; then
  CPUKind=$(getCPUKind)
  cores=$(sysctl -n hw.physicalcpu)

  echo "$CPUKind  ($cores cores, $threads threads)"
fi
