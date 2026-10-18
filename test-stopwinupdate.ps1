[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$source = Get-Content -Raw (Join-Path $PSScriptRoot 'StopWinUpdate.ps1')
$restore = Get-Content -Raw (Join-Path $PSScriptRoot 'Restore-WindowsUpdate.ps1')
$build = Get-Content -Raw (Join-Path $PSScriptRoot 'build-exe.ps1')
if ($source -notmatch 'RestoreAt') { throw '缺少可配置更新时间。' }
if ($source -notmatch 'AddYears\(100\)') { throw '默认期限不是 100 年。' }
if ($source -notmatch 'NoAutoUpdate') { throw '缺少 Windows Update 策略设置。' }
if ($source -notmatch 'schtasks\.exe /Create') { throw '缺少一次性恢复计划任务。' }
if ($build -notmatch '-requireAdmin') { throw 'EXE 未配置管理员清单。' }
if ($restore -notmatch 'Remove-ItemProperty') { throw '缺少手动恢复策略。' }
Write-Host '静态验收通过：配置、100 年默认期限、恢复任务、管理员清单、恢复脚本均存在。'
