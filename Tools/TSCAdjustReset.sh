#!/bin/bash

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

if [[ ! -f "${TSCAdjustResetInfoPlist}" ]]; then
  echo "The TSCAdjustReset Info.plist file doesn't exist."
  exit 1
fi


function getCPUKind() {
  PROCESSOR=$@

  PROCESSOR=$(printf "${PROCESSOR}" | perl -pe 's/\s+cpu//i')
  PROCESSOR=$(printf "${PROCESSOR}" | perl -pe 's/\(R\)//g and s/\(TM\)//ig')

  CPUKind=$(printf "${PROCESSOR}" | perl -pe 's/\s+@.*//')

  echo "${CPUKind}"
}

CPUKind=$(getCPUKind $(sysctl -n machdep.cpu.brand_string))
cores=$(sysctl -n hw.physicalcpu)
threads=$(sysctl -n hw.ncpu)
IOCPUNumber=$((${threads} - 1))

plutil -replace IOKitPersonalities.TSCAdjustReset.IOPropertyMatch.IOCPUNumber -integer ${IOCPUNumber} "${TSCAdjustResetInfoPlist}"

if [[ ${display} ]]; then
  echo -e "${CPUKind}  (${cores} cores, ${threads} threads)"
fi
