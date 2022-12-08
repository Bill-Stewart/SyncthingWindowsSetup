# Expand-Download.ps1
# Written by Bill Stewart (bstewart AT iname.com)

# Extracts the syncthing-windows-<platform>-v<version>.zip files for use with
# Syncthing Windows Setup (Syncthing.iss).

#requires -version 5

[CmdletBinding()]
param(
)

function Get-TempName {
  param(
    $path
  )
  do {
    $tempName = Join-Path $path ([IO.Path]::GetRandomFilename())
  }
  while ( Test-Path $tempName )
  $tempName
}

$ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

$Archive = Get-ChildItem (Join-Path $PSScriptRoot "syncthing-windows-*.zip") |
  Sort-Object LastWriteTime |
  Select-Object -Last 1
if ( $null -eq $Archive ) {
  throw "Copy the Windows Syncthing zip archive files here and try again."
}

$Version = [Regex]::Match($Archive.Name,
  '-v(\d+\.\d+\.\d+).zip',
  [Text.RegularExpressions.RegexOptions]::IgnoreCase).Groups[1].Value

if ( $Version -eq "" ) {
  throw "Failed to extract version number from install zip files."
}

$Archives = Get-ChildItem (Join-Path $PSScriptRoot ("syncthing-windows-*-v{0}.zip" -f $Version))
foreach ( $Archive in $Archives ) {
  $PlatformName = [Regex]::Match($Archive.Name,
  '-windows-([^-]+)-',
  [Text.RegularExpressions.RegexOptions]::IgnoreCase).Groups[1].Value
  if ( $PlatformName -eq "" ) {
    Write-Error ("Failed to extract platform name from file name '{0}'." -f $Archive.Name)
    continue
  }
  $TempPathName = Get-TempName $PSScriptRoot
  Expand-Archive $Archive.FullName $TempPathName
  if ( -not $? ) { continue }
  $PlatformDirName = Join-Path $PSScriptRoot "bin\$PlatformName"
  if ( -not (Test-Path $PlatformDirName) ) {
    New-Item $PlatformDirName -ItemType Directory | Out-Null
  }
  $VersionDirName = [IO.Path]::GetFileNameWithoutExtension($Archive.Name)
  Copy-Item "$TempPathName\$VersionDirName\syncthing.exe" $PlatformDirName
  $RedistPathName = Join-Path $PSScriptRoot "redist"
  if ( -not (Test-Path $RedistPathName) ) {
    New-Item $RedistPathName -ItemType Directory | Out-Null
  }
  Get-ChildItem "$TempPathName\$VersionDirName\*" -Exclude "*.exe" -File |
    Copy-Item -Destination $RedistPathName
  # Copy-Item "$TempPathName\$VersionDirName\extra" $RedistPathName -Force -Recurse
  Remove-Item $TempPathName -Force -Recurse
}
