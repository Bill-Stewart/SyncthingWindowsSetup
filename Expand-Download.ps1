# Expand-Download.ps1
# Written by Bill Stewart (bstewart AT iname.com)

# Extracts the syncthing-windows-<platform>-v<version>.zip files for use with
# Syncthing Windows Setup (Syncthing.iss).

#requires -version 3

[CmdletBinding()]
param(
)

# Converts text file to CRLF line terminators and preserves timestamp
function ConvertTo-CRLF {
  param(
    $fileName
  )
  $fullName = Resolve-Path -LiteralPath $fileName
  if ( $fullName ) {
    try {
      $content = [IO.File]::ReadAllText($fullName)
    }
    catch {
      Write-Error -Exception $_.Exception
      return
    }
    $newContent = $content -replace '(?<!\r)\n',"`r`n"
    try {
      $timeStamp = (Get-Item -LiteralPath $fullName).LastWriteTime
      [IO.File]::WriteAllText($fullName,$newContent)
      (Get-Item -LiteralPath $fullName).LastWriteTime = $timeStamp
    }
    catch {
      Write-Error -Exception $_.Exception
      return
    }
  }
}

function New-Version {
  [CmdletBinding()]
  param(
    [Version]
    $version
  )
  $major = [Math]::Max($version.Major,0)
  $minor = [Math]::Max($version.Minor,0)
  $build = [Math]::Max($version.Build,0)
  $revision = [Math]::Max($version.Revision,0)
  return New-Object Version($major,$minor,$build,$revision)
}

$ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

$Archiver = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)) "7-Zip\7z.exe"
Resolve-Path $Archiver | Out-Null

$Archive = Get-ChildItem (Join-Path $PSScriptRoot "syncthing-windows-*.zip") | Sort-Object LastWriteTime | Select-Object -Last 1
if ( $null -eq $Archive ) {
  throw "Copy the Windows Syncthing zip archive files here and try again."
}

$Version = [Regex]::Match($Archive.FullName,
  '-v(\d+\.\d+\.\d+).zip',
  [Text.RegularExpressions.RegexOptions]::IgnoreCase).Groups[1].Value

if ( $null -eq $Version ) {
  throw "Failed to extract version number from install zip files."
}

$ExtractBinDir = Join-Path $PSScriptRoot "bin"
$ExtractRedistDir = Join-Path $PSScriptRoot "redist"
$ExtractBinDir,$ExtractRedistDir | ForEach-Object {
  if ( Test-Path -LiteralPath $_ ) {
    Remove-Item $_ -Recurse
  }
  New-Item $_ -ItemType Directory | Out-Null
}

$Archives = Get-ChildItem (Join-Path $PSScriptRoot "syncthing-windows-*-v$Version.zip")
foreach ( $Archive in $Archives ) {
  $FileName = [IO.Path]::GetFileNameWithoutExtension((Split-Path $Archive.FullName -Leaf))
  $MatchList = [Regex]::Match($FileName,'-(?:(amd64)|(386))-',[Text.RegularExpressions.RegexOptions]::IgnoreCase)
  if ( $null -ne $MatchList ) {
    $MatchList | ForEach-Object {
      $Platform = if ( "" -ne $_.Groups[1].Value ) { $_.Groups[1].Value } else { $_.Groups[2].Value }
    }
    # Extract binary file to 'bin'
    & $Archiver x ("-o{0}" -f $ExtractBinDir) -r $Archive.FullName "syncthing.exe"
    if ( $LASTEXITCODE -ne 0 ) {
      break
    }
    # Rename extraction directory to platform name
    Rename-Item (Join-Path $ExtractBinDir $FileName) $Platform
    if ( $Platform -eq "amd64" ) {
      # Extract archive (with some exceptions) to redist
      & $Archiver x ("-o{0}" -f $ExtractRedistDir) -r "-xr!etc" "-xr!metadata" "-xr!syncthing.exe" $Archive.FullName
      if ( $LASTEXITCODE -ne 0 ) {
        break
      }
      # Move files from extract directory to redist
      Move-Item (Join-Path (Join-Path $ExtractRedistDir $FileName) "*") $ExtractRedistDir
      # Remove leftover empty directory
      Remove-Item (Join-Path $ExtractRedistDir $FileName)
    }
  }
}

# Convert text files to Windows (CRLF) format
Get-ChildItem (Join-Path (Join-Path $PSScriptRoot "redist") "*.txt") | ForEach-Object {
  ConvertTo-CRLF $_.FullName
}
