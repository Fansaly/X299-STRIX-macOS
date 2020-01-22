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
  - Launch CSM: **Disabled/Auto**

- **Boot/Secure Boot**
  - OS Type: **Other OS**

### 完成安装后
0. 打开 Terminal，安装开发者工具：
```sh
xcode-select --install
```
> 此时会收到系统会提示，根据提示完成安装

1. 下载此项目：
```sh
git clone https://github.com/Fansaly/X299-STRIX-macOS
cd X299-STRIX-macOS
```
2. 下载 工具、kext 和 hotpatch：
```sh
make download
```
> 可输入 `make download-tools` `make download-kexts` `make download-hotpatch` 分别单独下载
3. 解压缩上一步下载的文件：
```sh
make unarchive
```
4. 编译生成 DSDT/SSDT aml 文件：
```sh
make
```
5. 安装 DSDT/SSDT aml、kexts 和 drivers：
```sh
make install
```
> 可输入 `make install-aml` `make install-kexts` `make install-drivers` 分别单独安装
6. 手动替换 Clover 的 config.plist（可选）：
```sh
efi_dir=$(make mount)
cp config.plist ${efi_dir}/EFI/ClOVER
```
> 替换完成后，应该自定义 **SMBIOS** 中的 **Serial Number**、**Board Serial Number**、**SmUUID**，等等。

### Makefile 其它功能：
```sh
make mount              # 挂载 EFI 分区
make backup             # 备份 EFI/CLOVER
make update-kexts       # 检查 kexts 的更新
make upgrade-kexts      # 升级 kexts（下载/安装）
make update-kextcache   # 更新系统 kext 缓存
make update-repo        # 更新本地项目

make list-WebDriver n   # 获取最新的 n 个 NVIDIA Web Driver 信息
make download-WebDriver # 下载最新的 NVIDIA Web Driver
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
    - **VirtualSmc.efi** `由 make install-drivers 安装（无需额外操作）`

&nbsp;

### 已知问题
- **板载 Wi-Fi**：目前还没有解决方案。
- **睡眠／唤醒**：提示机箱前面板 USB 3.0 端口上的 U盘 已被弹出。
- **睡眠／唤醒**：小憩正常，熟睡大概 1h 吧会清醒一下，过不久接着再睡。

&nbsp;

### 致谢
acidanthera, apfelnico, interferenc, kgp, lvs1974, RehabMan, the-braveknight, vit9696, etc.
