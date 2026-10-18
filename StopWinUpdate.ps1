[CmdletBinding()]
param()

# ==================== 用户只需修改这里 ====================
# 更新时间：请改成希望 Windows Update 恢复的时间（本地时间）。
# 例如：$RestoreAt = [datetime]'2126-10-18 12:00:00'
# 留空则自动使用“当前时间 + 100 年”。
$RestoreAt = $null
# ==========================================================

$ErrorActionPreference = 'Stop'
$TaskName = 'StopWinUpdate-Restore'
$StatePath = Join-Path $env:ProgramData 'StopWinUpdate\restore.ps1'
$Services = @('wuauserv', 'bits', 'UsoSvc', 'WaaSMedicSvc')

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw '请在 UAC 提示中点击“是”后重新运行。'
    }
}

function Write-RestoreScript([datetime]$When) {
    $directory = Split-Path -Parent $StatePath
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $restore = @"
`$ErrorActionPreference = 'SilentlyContinue'
foreach (`$name in @('wuauserv','bits','UsoSvc','WaaSMedicSvc')) {
    Set-Service -Name `$name -StartupType Manual
    Start-Service -Name `$name
}
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name NoAutoUpdate -ErrorAction SilentlyContinue
schtasks.exe /Delete /TN '$TaskName' /F | Out-Null
"@
    Set-Content -Path $StatePath -Value $restore -Encoding UTF8
    return $directory
}

Assert-Administrator
if ($null -eq $RestoreAt) { $RestoreAt = (Get-Date).AddYears(100) }
if ($RestoreAt -le (Get-Date)) { throw '更新时间必须晚于当前时间。' }

$restoreDirectory = Write-RestoreScript $RestoreAt
foreach ($name in $Services) {
    Stop-Service -Name $name -Force -ErrorAction SilentlyContinue
    Set-Service -Name $name -StartupType Disabled -ErrorAction SilentlyContinue
}

$policyKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
New-Item -Path $policyKey -Force | Out-Null
New-ItemProperty -Path $policyKey -Name NoAutoUpdate -PropertyType DWord -Value 1 -Force | Out-Null

$time = $RestoreAt.ToString('HH:mm')
$date = $RestoreAt.ToString('MM/dd/yyyy')
schtasks.exe /Create /TN $TaskName /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$StatePath`"" /SC ONCE /ST $time /SD $date /RU SYSTEM /RL HIGHEST /F | Out-Null
Write-Host "已禁止 Windows 更新。恢复时间：$($RestoreAt.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Host '如需提前恢复，请以管理员身份运行 Restore-WindowsUpdate.ps1。'
