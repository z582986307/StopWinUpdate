[CmdletBinding()]
param([string]$Output = 'StopWinUpdate.exe')
$ErrorActionPreference = 'Stop'
$dependencyRoot = Join-Path $PSScriptRoot '项目依赖'
$modulePath = Get-ChildItem -Path $dependencyRoot -Directory -Filter 'ps2exe' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $modulePath) {
    New-Item -ItemType Directory -Path $dependencyRoot -Force | Out-Null
    Save-Module -Name ps2exe -Path $dependencyRoot -Force
    $modulePath = Get-ChildItem -Path $dependencyRoot -Directory -Filter 'ps2exe' | Select-Object -First 1
}
$moduleManifest = Get-ChildItem -Path $modulePath.FullName -Filter 'ps2exe.psd1' -Recurse | Select-Object -First 1
if ($null -eq $moduleManifest) { throw '未找到 ps2exe 模块清单。' }
Import-Module $moduleManifest.FullName -Force
Invoke-ps2exe -inputFile (Join-Path $PSScriptRoot 'StopWinUpdate.ps1') -outputFile (Join-Path $PSScriptRoot $Output) -requireAdmin -noConsole -title 'StopWinUpdate' -description 'Windows 更新控制工具' -product 'StopWinUpdate' -version '1.0.0.0'
Write-Host "已生成 $Output"
