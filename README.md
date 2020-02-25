The purpose of this guide is to improve **macOS High Sierra** that has been installed on PC of **ROG STRIX X299-E GAMING** motherboard.

### Translations
- [简体中文](README.zh_CN.md)

&nbsp;

DEVICE | MODEL
:-: | -
Motherboard | ROG STRIX X299-E GAMING
CPU | INTEL® CORE™ i7-7800X
Memory | CORSAIR VENGEANCE LPX DDR4 2400 16GB (8Gx2)
GPU | ROG STRIX-GTX1080-A8G-GAMING (Slot-1)
Disk | SAMSUNG 960 EVO 500G M.2 NVMe
Cooling | CORSAIR H100i V2
Power | CORSAIR RM650x
Mouse | LOGITECH G403
Keyboard | LOGITECH G413
Case | JONSBO UMX4

---

### BIOS
> **Before applying the settings, please update ROG STRIX X299-E GAMING BIOS firmware to 1301 or later.**  
> After executing **Exit/Load Optimized Defaults**, enable X.M.P in EZ Mode.  
> Switch between EZ Mode and Advanced Mode by pressing F7.

- **AI Tweaker**
  - ASUS MultiCore Enhancement: **Auto** *[optional "Disabled"]*
  - AVX Instruction Core Ratio Negative Offset: **Auto** *[optional "3"]*
  - AVX-512 Instruction Core Ratio Negative Offset: **Auto** *[optional "2"]*
  - CPU Core Ratio: **Auto** *[optional "Sync All Cores"]*
  - **CPU SVID Support: Enabled**
  - DRAM Frequency: **DDR4-2400MHz**

- **Advanced/CPU Configuration**
  - Hyper Threading [ALL]: **Enabled**
  - **MSR Lock Control: Disabled**

- **Advanced/CPU Configuration/CPU Power Management Configuration**
  - **Enhanced Intel Speed Step Technology (EIST): Enabled**
  - Autonomous Core C-States: **Enabled**
  - Enhanced Halt State (C1E): **Enabled**
  - CPU C6 report: **Enabled**
  - Package C-State: **C6(non retention) state**
  - **Intel SpeedShift Technology: Enabled**
  - MFC Mode Override: **OS Native**

- **Advanced/Platform Misc Configuration**
  - PCI Express Native Power Management: **Disabled**
  - PCH DMI ASPM: **Disabled**
  - ASPM: **Disabled**
  - DMI Link ASPM Control: **Disabled**
  - PEG - ASMP: **Disabled**

- **Advanced/System Agent Configuration**
  - Intel VT for Directed I/O (VT-d): **Disabled/Enabled**

- **Boot**
  - Fast Boot: **Disabled**
  - Above 4G Decoding: **Off** (must be **ON** with Prime X299 Deluxe BIOS firmware 1704, Strix X299-E Gaming BIOS firmware 1704 and WS X299 Sage/10G BIOS firmware 0905 in case of GPU firmware load and XHCI ACPI implementation issues. When employing WS X299 Sage/10G BIOS firmware 0905 and enabling Above 4G Decoding in the respective BIOS settings as required, _"First VGA 4G Decode"_ must be set to _"Auto"_, as both Windows 10 and macOS can become irresponsive with different _"First VGA 4G Decode"_ settings.)

- **Boot/Boot Configuration**
  - Boot Logo Display: **Auto**
  - Boot up NumLock State: **Disabled**
  - Setup Mode: **Advanced**

- **Boot/Compatibility Support Module**
  - Launch CSM: **Disabled/Auto**

- **Boot/Secure Boot**
  - OS Type: **Other OS**

### POST INSTALLATION
> See the **README** in the `Config` directory to configure the appropriate tools, kext, and hotpatch.

0. open Terminal, install developer tools:
```sh
xcode-select --install
```
> you will be prompted to install the developer tools, complete the installation.

1. clone this repo:
```sh
git clone https://github.com/Fansaly/X299-STRIX-macOS
cd X299-STRIX-macOS
```
2. download tools, kexts, and hotpatch:
```sh
make download
```
> type `make download-tools` `make download-kexts` `make download-hotpatch-bplan` to download separately
3. uncompress files of previous step:
```sh
make unarchive
```
4. build DSDT/SSDT aml:
```sh
make
```
5. install DSDT/SSDT aml, kexts and drivers:
```sh
make install
```
> type `make install-aml` `make install-kexts` `make install-drivers` to install separately
6. manually replace config.plist for Clover (optional):
```sh
efi_dir=$(make mount)
cp config.plist ${efi_dir}/EFI/ClOVER
```
> after the replacement, you should customize **Serial Number**, **Board Serial Number**, **SmUUID** in **SMBIOS** section, and etc.

### Other features of Makefile:
```sh
make mount              # Mount EFI partition
make backup             # Backup EFI/CLOVER
make update-kexts       # Check kexts updates
make upgrade-kexts      # Upgrade kexts (Download/Install)
make update-kextcache   # Update system kext caches
make update-repo        # Update local repo.

make list-WebDriver n   # Print the latest first n of NVIDIA Web Driver info.
make download-WebDriver # Download the latest NVIDIA Web Driver
```

### EFI/CLOVER/drivers/UEFI
  - Recommended
    - **FSInject.efi**
  - File System
    - **ApfsDriverLoader.efi**
    - **VBoxHfs.efi**
  - Memory fix
    - **AptioMemoryFix.efi**
  - Custom
    - **VirtualSmc.efi** `install by make install-drivers (No need to worry)`

&nbsp;

### Known Issues
- **Onboard Wi-Fi**: There is currently no solution.
- **Sleep/Wake**: Prompt that USB Flash Drive on front panel USB 3.0 port has been Ejected.
- **Sleep/Wake**: Power nap is normal, sleep about 1h maybe, it will wake up, and then go to sleep soon.

&nbsp;

### Credits
acidanthera, apfelnico, interferenc, kgp, lvs1974, RehabMan, the-braveknight, vit9696, etc.
