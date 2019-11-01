本指南旨在完善已安装在 **ROG STRIX X299-E GAMING** 主板的 PC 上的 **macOS High Sierra**。

&nbsp;

设备 | 型号
:-: | -
主板 | ROG STRIX X299-E GAMING
CPU | INTEL® CORE™ i7-7800X
内存 | CORSAIR VENGEANCE LPX DDR4 2400 16GB (8Gx2)
显卡 | ROG STRIX-GTX1080-A8G-GAMING (Slot-1)
硬盘 | SAMSUNG 960 EVO 500G M.2 NVMe
水冷 | CORSAIR H100i V2
电源 | CORSAIR RM650x
鼠标 | LOGITECH G403
键盘 | LOGITECH G413
机箱 | JONSBO UMX4

---

### BIOS
> **在设置之前，请先将 ROG STRIX X299-E GAMING 的 BIOS 版本更新到 1301 或更高。**  
> 执行 **Exit/Load Optimized Defaults** 之后，在 EZ Mode 下启用 X.M.P。  
> 通过按 F7 在 EZ Mode 和 Advanced Mode 之间切换。

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
  - Above 4G Decoding: **Off** (Prime X299 Deluxe BIOS 和 Strix X299-E Gaming BIOS 的 1704 版本固件，以及 WS X299 Sage/10G BIOS 的 0905 版本固件，会在加载 GPU 和 XHCI ACPI 过程发生故障，必须设置为 **ON**。在使用 WS X299 Sage/10G BIOS 的 0905 版本固件时，在 BIOS 中启用 Above 4G Decoding，并按需设置其他项目，此外还必须将 _"First VGA 4G Decode"_ 设置为 _"Auto"_，因为 Windows 10 和 macOS 都不能正确响应不同的 _"First VGA 4G Decode"_ 设置。)

- **Boot/Boot Configuration**
  - Boot Logo Display: **Auto**
  - Boot up NumLock State: **Disabled**
  - Setup Mode: **Advanced**

- **Boot/Compatibility Support Module**
  - Launch CSM: **Disabled**

- **Boot/Secure Boot**
  - OS Type: **Other OS**

### 安装完成后
1. 下载此项目：
```bash
git clone https://github.com/Fansaly/X299-STRIX-macOS
cd X299-STRIX-macOS
```
2. 下载 工具、kext 和 hotpatch：
```bash
make download
```
3. 解压缩上一步下载的文件：
```bash
make unarchive
```
4. 编译生成 DSDT/SSDT aml 文件：
```bash
make build
```
5. 安装 DSDT/SSDT aml 和 kexts：
```bash
make install
```
6. 手动替换 CLOVER 的 config.plist：
```bash
efi_dir=$(make mount)
cp config.plist ${efi_dir}/EFI/ClOVER
```
替换完成后，应该自定义 SMBIOS 中的 Serial Number、Board Serial Number、SmUUID，等等。

7. 其它功能：
```bash
make update-kexts  # 检查 kexts 的更新
make upgrade-kexts # 升级 kexts
make backup        # 备份 EFI/CLOVER
make update-repo   # 更新本地项目库

make list-WebDriver n   # 获取最新的 n 个 NVIDIA Web Driver 信息
make download-WebDriver # 下载最新的 NVIDIA Web Driver
```

### EFI/CLOVER/drivers/UEFI
  - Recommended
    - AudioDxe.efi
    - DataHubDxe.efi
    - FSInject.efi
    - SMCHelper.efi
  - File System
    - ApfsDriverLoader.efi
    - VBoxHfs.efi
  - Memory fix
    - AptioMemoryFix.efi


&nbsp;

### 已知问题
- **板载 Wi-Fi**：目前还没有解决方案。
- **睡眠／唤醒**：提示机箱前面板 USB 3.0 端口上的 U盘 已被弹出。
- **睡眠／唤醒**：小憩正常，熟睡大概 1h 吧会清醒一下，过不久接着再睡。

&nbsp;

### 致谢
acidanthera, interferenc, kgp, lvs1974, RehabMan, the-braveknight, vit9696, etc.
