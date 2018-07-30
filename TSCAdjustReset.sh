#!/bin/bash

function getCPUKind() {
    PROCESSOR=$@

    PROCESSOR=$(printf "${PROCESSOR}" | perl -pe 's/\s+cpu//i')
    PROCESSOR=$(printf "${PROCESSOR}" | perl -pe 's/\(R\)//g and s/\(TM\)//ig')

    CPUKind=$(printf "${PROCESSOR}" | perl -pe 's/\s+@.*//')

    echo "${CPUKind}"
}

case "$1" in
    --quiet)
        quiet=1
    ;;
esac

CPUKind=$(getCPUKind $(sysctl -n machdep.cpu.brand_string))
cores=$(sysctl -n hw.physicalcpu)
threads=$(sysctl -n hw.ncpu)
IOCPUNumber=$((${threads} - 1))

TSCAdjustResetInfoPlist=Kexts/TSCAdjustReset.kext/Contents/Info.plist

if [[ ! -f "${TSCAdjustResetInfoPlist}" ]]; then
    echo "The TSCAdjustReset Info.plist file doesn't exist."
    exit 0
fi

plutil -replace IOKitPersonalities.TSCAdjustReset.IOPropertyMatch.IOCPUNumber -integer ${IOCPUNumber} "${TSCAdjustResetInfoPlist}"

if [[ ! ${quiet} ]]; then
    echo -e "${CPUKind}  (${cores} cores, ${threads} threads)"
fi
