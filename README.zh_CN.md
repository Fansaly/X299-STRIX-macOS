本指南是在使用 ROG STRIX X299-E GAMING 主板的 PC 上安装 macOS High Sierra。

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
  - Above 4G Decoding: **Off** (must be **ON** with BIOS firmware 1704 and WS X299 Sage 10G BIOS firmware 0905 in case of GPU firmware load and XHCI ACPI implementation issues. When employing WS X299 Sage 10G BIOS firmware 0905 and enabling Above 4G Decoding in the respective BIOS settings as required, _"First VGA 4G Decode"_ must be set to _"Auto"_, as both Windows 10 and macOS can become irresponsive with different _"First VGA 4G Decode"_ settings.)

- **Boot/Boot Configuration**
  - Boot Logo Display: **Auto**
  - Boot up NumLock State: **Disabled**
  - Setup Mode: **Advanced**

- **Boot/Compatibility Support Module**
  - Launch CSM: **Disabled**

- **Boot/Secure Boot**
  - OS Type: **Other OS**

### 步骤
1. 下载此项目：
```bash
git clone https://github.com/Fansaly/X299-STRIX-macOS
```
2. 下载 工具、kext 和 hotpatch：
```bash
make download
```
3. 解压缩上一步下载的文件：
```bash
make unarchive
```
4. 编译生成 DSDT/SSDT 的 aml 文件：
```bash
make build
```
5. 安装 DSDT/SSDT aml 和 kexts：
```bash
make install
```
6. 可手动替换 CLOVER 的 config.plist：
```bash
efi_dir=$(make mount)
cp config.plist ${efi_dir}/EFI/ClOVER
```
替换完成后，应该自定义 SMBIOS 中的 Serial Number、Board Serial Number、SmUUID。
7. 其它功能：
```bash
make check-kexts  # 检查下载 kexts 的更新
make backup       # 备份 EFI/CLOVER
make update       # 更新本地项目库
```

### EFI/CLOVER/drivers64UEFI（CLOVER 默认安装的）
  - [x] ApfsDriverLoader-64.efi
  - [x] AppleImageLoader-64.efi
  - [x] AptioMemoryFix-64.efi
  - [x] AudioDxe-64.efi
  - [x] DataHubDxe-64.efi
  - [x] FSInject-64.efi
  - [x] SMCHelper-64.efi
  - [x] VBoxHfs-64.efi

### 其他
如果 About This Mac->Processor 显示“未知”，可参考「[此项目](https://github.com/Fansaly/CosmetiCPUKind)」设置你所需的。

&nbsp;

### 已知问题
- **板载 Wi-Fi**：目前还没有解决方案。
- **睡眠／唤醒**：提示机箱前面板 USB 3.0 端口上的 U盘 已被弹出。
- **睡眠／唤醒**：小憩正常，熟睡大概 1h 吧会清醒一下，过不久接着再睡。

&nbsp;

### 致谢
acidanthera, interferenc, kgp, lvs1974, RehabMan, the-braveknight, vit9696, etc.
