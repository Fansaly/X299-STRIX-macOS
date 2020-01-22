### TSCAdjustReset.kext
> Last sync: [[3456c2e]](https://github.com/interferenc/TSCAdjustReset/tree/3456c2ea16a6e4e40cdf7dd5374f22b8103538e8)
>
> The kext here is compiled and the correct IOCPUNumber is set automatically by `Tools/set_tsc.sh`.  
> The following are the specific steps to compile and modify the source code for this kext.

This kernel extension fixes the consequences of unsynchronized TSC when booting macOS on an X299 board with Skylake-X CPUs.

Download the TSCAdjustRest.kext source from Github and compile it with Xcode:
```bash
git clone https://github.com/interferenc/TSCAdjustReset
cd TSCAdjustReset
xcodebuild
```

After successful compilation, you will find the TSCAdjustRest.kext in `TSCAdjustReset/build/Release/`

Please note that the TSCAdjustRest.kext by default is configured for a 8-core CPU (16 threads).  
To adopt the kext for Skylake-X processers with more or less cores than 8 cores,  
apply the following approach:

> 1.) Right-click on the TSCAdjustRest.kext folder and select "Show Packet Contents".  
> 2.) Open the content directory and edit the Info.plist file.  
> 3.) "Find" the IOCPUNumber item.  
> 4.) Note that IOCPUNumber for the Skylake-X processor is the number of its `threads - 1`

So, the correct IOCPUNumber for the 6-core i7-7800X should be 11 (12 threads -1)
```xml
<key>IOCPUNumber</key>
<integer>11</integer>
```

### AGPMEnabler.kext
Enable AGPM, Learn more (tonymacx86): https://bit.ly/2yo8oBb

> Last sync: 2018-06-13T02:24:24+0100
>
> "AppleGraphicsPowerManagement.kext" is unchanged, plus the "AGPMEnabler.kext" in Clover.  
> Inspired by the iMacPro and Toleda, actually no big deal.  
> No "device-id", no "vendor-id", just graphics card is "GFX0" in "Mac-7BA5B2D9E42DDD94" (iMac Pro).
