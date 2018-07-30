### TSCAdjustReset.kext
> 此处的 kext 是已编译完成的，并由 `TSCAdjustReset.sh` 自动完成设置正确的 IOCPUNumber。  
> 以下只是对此 kext 的源码编译和修改的具体步骤。

此内核扩展修复了在使用 Skylake-X CPU 的 X299 主板上启动 macOS 时 TSC 未同步的问题。

从 Github 下载 TSCAdjustRest.kext 源码，并用 Xcode 编译：
```bash
git clone https://github.com/interferenc/TSCAdjustReset
cd TSCAdjustReset
xcodebuild
```

编译成功后，可以在 `TSCAdjustReset/build/Release/` 中找到 TSCAdjustRest.kext。  

默认情况下，TSCAdjustRest.kext 配置为 8 核心 CPU（16 线程）。  
若要应用于多于或少于 8 个内核的 Skylake-X 处理器，  
请依照以下步骤修改：

> 1.) 右击 TSCAdjustRest.kext 文件夹，并选择“显示包内容”。  
> 2.) 打开 contents 目录，编辑 Info.plist 文件。  
> 3.) 查找 IOCPUNumber 条目。  
> 4.) 注意 IOCPUNumber 为 Skylake-X 处理器的 `线程数 - 1`

那么，6 核心 i7-7800X 的 IOCPUNumber 应为 11（12 个线程 - 1）
```xml
<key>IOCPUNumber</key>
<integer>11</integer>
```
