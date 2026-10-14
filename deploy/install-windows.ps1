# Run once per machine from an elevated PowerShell:
#   .\install-windows.ps1 -Exe .\rustdesk.exe -Password 'permanent-password' `
#       [-IdServer host] [-Key pubkey] [-RelayServer host]
# Installs RustDesk as a Windows service that starts at boot, before any user
# logs in, and sets the permanent password used for unattended access.
param(
    [Parameter(Mandatory)] [string] $Exe,
    [Parameter(Mandatory)] [string] $Password,
    [string] $IdServer,
    [string] $Key,
    [string] $RelayServer
)
$ErrorActionPreference = 'Stop'
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole('Administrator')) {
    throw 'Run this script as Administrator.'
}

Start-Process -FilePath $Exe -ArgumentList '--silent-install' -Wait
$installed = Join-Path ${env:ProgramFiles} 'RustDesk\rustdesk.exe'
if (-not (Test-Path $installed)) { throw "Install failed: $installed not found." }

# The service needs a moment to come up before it accepts CLI changes.
Start-Sleep -Seconds 8
if ($IdServer)     { & $installed --option custom-rendezvous-server $IdServer }
if ($Key)          { & $installed --option key $Key }
if ($RelayServer)  { & $installed --option relay-server $RelayServer }
& $installed --password $Password

Start-Sleep -Seconds 2
$id = & $installed --get-id
Write-Host "Installed. This machine's ID: $id"
