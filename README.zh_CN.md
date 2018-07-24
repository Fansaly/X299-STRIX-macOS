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
  - **CPU SVID Support: Enabled** *[fundamental for proper IPG CPU power consumption display]*
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
  - **Intel SpeedShift Technology: Enabled** *(crucial for native HWP Intel SpeedShift Technology CPU Power Management)*
  - MFC Mode Override: **OS Native**

- **Advanced/Platform Misc Configuration**
  - PCI Express Native Power Management: **Disabled**
  - PCH DMI ASPM: **Disabled**
  - ASPM: **Disabled**
  - DMI Link ASPM Control: **Disabled**
  - PEG - ASMP: **Disabled**

- **Advanced/System Agent Configuration**
  - Intel VT for Directed I/O (VT-d): **Disabled**

- **Boot**
  - Fast Boot: **Disabled**
  - Above 4G Decoding: **Off**

- **Boot/Boot Configuration**
  - Boot Logo Display: **Auto**
  - Boot up NumLock State: **Disabled**
  - Setup Mode: **Advanced**

- **Boot/Compatibility Support Module**
  - Launch CSM: **Disabled**

- **Boot/Secure Boot**
  - OS Type: **Other OS**


### KEXT+ACPI
下载此项目到本地：
```bash
git clone https://github.com/Fansaly/X299-STRIX-macOS
```

下载 kext 和 工具，并安装：
```bash
cd X299-STRIX-macOS
./X299-STRIX.sh --download
./X299-STRIX.sh --install
```

`--download` 从 Bitbucket、GitHub 下载最新的工具（iasl）和 kext（FakeSMC.kext、IntelMausiEthernet.kext，等等），以及所需的 hotpatch SSDTs。  
`--install` 将它们安装到正确位置。

编译 ACPI 补丁，并应用：
```bash
cd X299-STRIX-macOS
make
make install
```

`make` 用来编译打好补丁的文件（需要 iasl），生成的文件位于目录 `./Build`。  
`make install` 先挂载 EFI 分区，再复制编译生成的文件到 `EFI/CLOVER/ACPI/patched`。  
`make clean` 删除位于 `./Build` 中的 AML 文件。

### config.list
替换 `EFI/CLOVER/config.plist` 为仓库中的 config.plist。

```bash
cd X299-STRIX-macOS
./X299-STRIX.sh --install-config
```

替换完成后，应该自定义 SMBIOS 中的 Serial Number、Board Serial Number、SmUUID。

### EFI/CLOVER/drivers64UEFI
  - [x] ApfsDriverLoader.efi
  - [x] AppleImageCodec-64.efi
  - [x] AppleKeyAggregator-64.efi
  - [x] AppleUITheme-64.efi
  - [x] AptioMemoryFix.efi
  - [x] DataHubDxe-64.efi
  - [x] FirmwareVolume-64.efi
  - [x] FSInject-64.efi

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
