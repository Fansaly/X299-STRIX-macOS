#!/bin/bash

#set -x

downloads=Downloads

local_kexts_dir=Kexts
kexts_dir=$downloads/Kexts

tools_dir=$downloads/Tools

hotpatch_dir=Hotpatch/Downloads

if [[ ! -d macos-tools ]]; then
    echo "Downloading latest macos-tools..."
    rm -Rf macos-tools && git clone https://github.com/the-braveknight/macos-tools --quiet
fi

function findKext() {
    find $kexts_dir $local_kexts_dir -name $1 -not -path \*/PlugIns/* -not -path \*/Debug/*
}

case "$1" in
    --download-tools)
        rm -Rf $tools_dir && mkdir -p $tools_dir

        macos-tools/bitbucket_download.sh -a RehabMan -r acpica -o $tools_dir
    ;;
    --download-kexts)
        rm -Rf $kexts_dir && mkdir -p $kexts_dir

        # Bitbucket kexts
        macos-tools/bitbucket_download.sh -a RehabMan -r os-x-fakesmc-kozlek -o $kexts_dir
        macos-tools/bitbucket_download.sh -a RehabMan -r os-x-intel-network -o $kexts_dir

        # GitHub kexts
        macos-tools/github_download.sh -a acidanthera -r Lilu -o $kexts_dir
        macos-tools/github_download.sh -a acidanthera -r AppleALC -o $kexts_dir
        macos-tools/github_download.sh -a lvs1974 -r HibernationFixup -o $kexts_dir
        macos-tools/github_download.sh -a lvs1974 -r NvidiaGraphicsFixup -o $kexts_dir
    ;;
    --download-hotpatch)
        rm -Rf $hotpatch_dir && mkdir -p $hotpatch_dir

        macos-tools/hotpatch_download.sh -o $hotpatch_dir SSDT-XOSI.dsl
    ;;
    --unarchive-downloads)
        macos-tools/unarchive.sh -d $downloads
    ;;
    --install-kexts)
        macos-tools/install_kext.sh -i $(findKext FakeSMC.kext)
        macos-tools/install_kext.sh -i $(findKext Lilu.kext)
        macos-tools/install_kext.sh -i $(findKext AppleALC.kext)
        macos-tools/install_kext.sh -i $(findKext IntelMausiEthernet.kext)
        macos-tools/install_kext.sh -i $(findKext HibernationFixup.kext)
        macos-tools/install_kext.sh -i $(findKext NvidiaGraphicsFixup.kext)
        $0 --install-tscadjustreset
    ;;
    --install-tscadjustreset)
        ./TSCAdjustReset.sh --quiet
        macos-tools/install_kext.sh -i Kexts/TSCAdjustReset.kext
    ;;
    --install-config)
        macos-tools/install_config.sh config.plist
    ;;
    --download)
        $0 --download-kexts
        $0 --download-tools
        $0 --download-hotpatch
    ;;
    --install)
        $0 --unarchive-downloads
        $0 --install-kexts
    ;;
esac
