# StopWinUpdate

Windows 10/11 Windows Update 控制工具。

## 使用

双击 `StopWinUpdate.exe`，在 UAC 提示中点击“是”即可，不需要先手动选择“以管理员身份运行”。工具会停止并禁用相关更新服务，设置策略限制，并创建一次性恢复任务。EXE 已内置 `requireAdministrator` 权限清单。

默认恢复时间为执行时刻之后 100 年。

## 修改更新时间

如果需要指定恢复时间，编辑 `StopWinUpdate.ps1` 顶部的 `$RestoreAt`，只修改这一行，例如：

```powershell
$RestoreAt = [datetime]'2030-01-01 08:00:00'
```

修改后运行 `build-exe.ps1` 重新生成 EXE。请使用 `yyyy-MM-dd HH:mm:ss` 格式。

## 提前恢复

以 UAC 提示点击“是”的方式运行 `Restore-WindowsUpdate.ps1`，它会恢复服务启动方式、移除策略并删除恢复任务。

## 构建

需要 PowerShell 5.1 或更高版本及网络连接以获取本地 `ps2exe` 构建依赖。构建依赖会保存到 `项目依赖`，不会写入系统级环境变量。

## 注意

Windows 版本、组织策略或安全软件可能覆盖本工具设置；家庭/企业环境请遵守管理员和组织策略。工具不会删除 Windows 更新文件，也不会保证永久阻止所有 Microsoft 更新通道。
