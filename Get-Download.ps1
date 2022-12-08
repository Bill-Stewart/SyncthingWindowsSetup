#requires -version 5

function Get-WebContent {
  param(
    [String]
    $url
  )
  (Invoke-WebRequest $url -UseBasicParsing |
    Select-Object -ExpandProperty Content) -split "`n"
}

function Get-RemoteFile {
  param(
    [String]
    $url,

    [String]
    $localFileName
  )
  Write-Verbose "Download: $url" -Verbose
  Invoke-WebRequest $url -OutFile $localFileName
}

$Platforms = @(
  "386"
  "amd64"
  "arm64"
)

Get-WebContent "https://syncthing.net/downloads/" |
  Select-String 'https:\/\/\S+(syncthing-windows-(\S+)-v(\d+\.\d+\.\d+)\.zip)' |
  ForEach-Object {
    if ( $Platforms -contains $_.Matches[0].Groups[2].Value ) {
      Get-RemoteFile $_.Matches[0].Value (Join-Path $PSScriptRoot $_.Matches[0].Groups[1].Value)
    }
  }
