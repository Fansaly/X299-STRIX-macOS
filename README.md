This guide is to install macOS High Sierra on a PC that uses the ROG STRIX X299-E GAMING motherboard.

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
  - Above 4G Decoding: **Off** (must be **ON** with BIOS firmware 1704 and WS X299 Sage 10G BIOS firmware 0905 in case of GPU firmware load and XHCI ACPI implementation issues. When employing WS X299 Sage 10G BIOS firmware 0905 and enabling Above 4G Decoding in the respective BIOS settings as required, _"First VGA 4G Decode"_ must be set to _"Auto"_, as both Windows 10 and macOS can become irresponsive with different _"First VGA 4G Decode"_ settings.)

- **Boot/Boot Configuration**
  - Boot Logo Display: **Auto**
  - Boot up NumLock State: **Disabled**
  - Setup Mode: **Advanced**

- **Boot/Compatibility Support Module**
  - Launch CSM: **Disabled**

- **Boot/Secure Boot**
  - OS Type: **Other OS**

### SETUP
1. clone this repo:
```bash
git clone https://github.com/Fansaly/X299-STRIX-macOS
cd X299-STRIX-macOS
```
2. download tools, kexts, and hotpatch:
```bash
make download
```
3. unzip files from previous step:
```bash
make unarchive
```
4. build DSDT/SSDT aml:
```bash
make build
```
5. install DSDT/SSDT aml and kexts:
```bash
make install
```
6. manually replace config.plist for CLOVER:
```bash
efi_dir=$(make mount)
cp config.plist ${efi_dir}/EFI/ClOVER
```
After the replacement, you should customize Serial Number, Board Serial Number, SmUUID in SMBIOS section.  
7. other features:
```bash
make check-kexts  # Check for updates for download kexts
make backup       # Backup EFI/CLOVER
make update       # Update local repo.
```

### EFI/CLOVER/drivers64UEFI (CLOVER installed by default)
  - [x] ApfsDriverLoader-64.efi
  - [x] AppleImageLoader-64.efi
  - [x] AptioMemoryFix-64.efi
  - [x] AudioDxe-64.efi
  - [x] DataHubDxe-64.efi
  - [x] FSInject-64.efi
  - [x] SMCHelper-64.efi
  - [x] VBoxHfs-64.efi

### Other
If About This Mac->Processor displays "Unknown", you can refer to「[This Project](https://github.com/Fansaly/CosmetiCPUKind)」to set up what you need.

&nbsp;

### Known Issues
- **Onboard Wi-Fi**: There is currently no solution.
- **Sleep/Wake**: Prompt that USB Flash Drive on front panel USB 3.0 port has been Ejected.
- **Sleep/Wake**: Power nap is normal, sleep about 1h maybe, it will wake up, and then go to sleep soon.

&nbsp;

### Credits
acidanthera, interferenc, kgp, lvs1974, RehabMan, the-braveknight, vit9696, etc.
