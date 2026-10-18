[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw '请在 UAC 提示中点击“是”。' }
foreach ($name in @('wuauserv','bits','UsoSvc','WaaSMedicSvc')) {
    Set-Service -Name $name -StartupType Manual -ErrorAction SilentlyContinue
    Start-Service -Name $name -ErrorAction SilentlyContinue
}
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name NoAutoUpdate -ErrorAction SilentlyContinue
schtasks.exe /Delete /TN 'StopWinUpdate-Restore' /F | Out-Null
Write-Host 'Windows 更新服务已恢复为手动启动，策略限制已移除。'
