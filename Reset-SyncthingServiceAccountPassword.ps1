#requires -version 2

<#
.SYNOPSIS
Resets the Syncthing local service account password to a long, random password.

.DESCRIPTION
Resets the Syncthing local service account password to a long, random password.

.PARAMETER ServiceAccountUserName
Specifies the username of the local service user account.
#>

[CmdletBinding()]
param(
  [Parameter(Position = 0,Mandatory)]
  [String]
  $ServiceAccountUserName
)

Add-Type -TypeDefinition @'
// For the local user management functions, we'll use PowerShell "wrapper"
// functions to call the Win32 APIs
namespace A2AD3FBFC8B64958A20D7A414B0A6BB5 {
  using System;
  using System.Runtime.InteropServices;

  public class NetApi32 : IDisposable {
    // [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32+USER_INFO_2]
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    public struct USER_INFO_2 {
      public string usri2_name;
      public string usri2_password;
      public uint   usri2_password_age;
      public uint   usri2_priv;
      public string usri2_home_dir;
      public string usri2_comment;
      public uint   usri2_flags;
      public string usri2_script_path;
      public uint   usri2_auth_flags;
      public string usri2_full_name;
      public string usri2_usr_comment;
      public string usri2_parms;
      public string usri2_workstations;
      public uint   usri2_last_logon;
      public uint   usri2_last_logoff;
      public uint   usri2_acct_expires;
      public uint   usri2_max_storage;
      public uint   usri2_units_per_week;
      public IntPtr usri2_logon_hours;
      public uint   usri2_bad_pw_count;
      public uint   usri2_num_logons;
      public string usri2_logon_server;
      public uint   usri2_country_code;
      public uint   usri2_code_page;
    }

    // [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetUserGetInfo()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetUserGetInfo(
      string     servername,
      string     username,
      uint       level,
      out IntPtr bufptr);

    // [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetUserSetInfo()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetUserSetInfo(
      string   servername,
      string   username,
      uint     level,
      IntPtr   bufptr,
      out uint parm_err);

    // [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetApiBufferFree()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetApiBufferFree(IntPtr Buffer);

    public void Dispose() {
    }
  }
}
'@

$ERROR_FILE_NOT_FOUND     = 2
$ERROR_ELEVATION_REQUIRED = 740
$RANDOM_PASSWORD_LENGTH   = 127
$UF_ACCOUNTDISABLE        = 0x00002
$UF_LOCKOUT               = 0x00010
$UF_DONT_EXPIRE_PASSWD    = 0x10000

# Returns a random SecureString containing the specified # of characters
function New-RandomSecureString {
  param(
    [UInt32]
    $length
  )
  $byteCount = [Math]::Ceiling((($length * 6) + 7) / 8)
  $bytes = New-Object Byte[] $byteCount
  $pRNG = New-Object Security.Cryptography.RNGCryptoServiceProvider
  $pRNG.GetBytes($bytes)
  [Convert]::ToBase64String($bytes).Substring(0,$length) |
    ConvertTo-SecureString -AsPlainText -Force
}

# Returns a SecureString as a plain-text string
function ConvertTo-String {
  param(
    [Security.SecureString]
    $secureString
  )
  try {
    $bSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
    [Runtime.InteropServices.Marshal]::PtrToStringAuto($bSTR)
  }
  finally {
    if ( $bSTR -ne [IntPtr]::Zero ) {
      [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bSTR)
    }
  }
}

# P/Invoke
# Retrieves USER_INFO_2 object for a local user account; returns 0 for success,
# non-zero for failure
function Invoke-NetUserGetInfo {
  param(
    [String]
    $accountName,

    [Ref]
    $userInfo2
  )
  $result = 0
  $pUserInfo2 = [IntPtr]::Zero
  try {
    $result = [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetUserGetInfo(
      $null,              # servername
      $accountName,       # username
      2,                  # level
      [Ref] $pUserInfo2)  # bufptr
    if ( $result -eq 0 ) {
      # Copy the unmanaged buffer to the managed object
      # Value property is required because it's a [Ref] parameter
      $userInfo2.Value = [Runtime.InteropServices.Marshal]::PtrToStructure($pUserInfo2,
        [Type] [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32+USER_INFO_2])
    }
  }
  finally {
    if ( $pUserInfo2 -ne [IntPtr]::Zero ) {
      # Free the unmanaged buffer
      [Void] [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetApiBufferFree($pUserInfo2)
    }
  }
  return $result
}

# P/Invoke
# Resets the attributes of a local user account; returns 0 for success,
# non-zero for failure
function Reset-LocalUserAccount {
  param(
    [String]
    $accountName,

    [Security.SecureString]
    $password
  )
  $userInfo2 = $null
  $result = Invoke-NetUserGetInfo $accountName ([Ref] $userInfo2)
  if ( $result -ne 0 ) {
    return $result
  }
  # Reset password
  $userInfo2.usri2_password = (ConvertTo-String $password)
  # Enable if disabled
  if ( ($userInfo2.usri2_flags -band $UF_ACCOUNTDISABLE) -ne 0 ) {
    $userInfo2.usri2_flags = $userInfo2.usri2_flags -band (-bnot $UF_ACCOUNTDISABLE)
  }
  # Clear lockout if locked out
  if ( ($userInfo2.usri2_flags -band $UF_LOCKOUT) -ne 0 ) {
    $userInfo2.usri2_flags = $userInfo2.usri2_flags -band (-bnot $UF_LOCKOUT)
  }
  # Set "Password never expires" if not set
  if ( ($userInfo2.usri2_flags -band $UF_DONT_EXPIRE_PASSWD) -eq 0 ) {
    $userInfo2.usri2_flags = $userInfo2.usri2_flags -bor $UF_DONT_EXPIRE_PASSWD
  }
  # Do not change logon hours
  $userInfo2.usri2_logon_hours = [IntPtr]::Zero
  try {
    # Allocate memory for unmanaged USER_INFO_2 buffer
    $pUserInfo2 = [Runtime.InteropServices.Marshal]::AllocHGlobal([Runtime.InteropServices.Marshal]::SizeOf($userInfo2))
    # Copy the managed object to it
    [Runtime.InteropServices.Marshal]::StructureToPtr($userInfo2,$pUserInfo2,$false)
    $parmErr = 0
    [A2AD3FBFC8B64958A20D7A414B0A6BB5.NetApi32]::NetUserSetInfo(
      $null,           # servername
      $accountName,    # username
      2,               # level
      $pUserInfo2,     # buf
      [Ref] $parmErr)  # parm_err
  }
  finally {
    # Free the unmanaged buffer
    [Runtime.InteropServices.Marshal]::FreeHGlobal($pUserInfo2)
  }
}

# Returns $true if the current session is elevated (PSv2-compatible), or
# $false otherwise
function Test-Elevation {
  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Outputs the message associated with a message id; -asError parameter causes
# output as an error message - "Error <n> (0x<n>) - <message>"
function Get-MessageDescription {
  param(
    $messageId,

    [Switch]
    $asError
  )
  # Message ID must be Int32
  $intId = [BitConverter]::ToInt32([BitConverter]::GetBytes($messageId),0)
  $message = ([ComponentModel.Win32Exception] $intId).Message
  if ( $asError ) {
    "Error {0} (0x{0:X}) - {1}." -f $messageId,$message
  }
  else {
    "{0}." -f $message
  }
}

function Start-Program {
  param(
    [String]
    $filePath,

    [String[]]
    $argumentList
  )
  if ( Test-Path -LiteralPath $filePath ) {
    $params = @{
      "FilePath"     = $filePath
      "ArgumentList" = $argumentList
      "PassThru"     = $true
      "Wait"         = $true
      "WindowStyle"  = "Hidden"
    }
    $process = Start-Process @params
    return $process.ExitCode
  }
  else {
    return $ERROR_FILE_NOT_FOUND
  }
}

function ResetServiceAccountPassword {
  param(
    [String]
    $serviceAccountUserName,

    [String]
    $serviceName
  )
  $serviceAccountPassword = New-RandomSecureString $RANDOM_PASSWORD_LENGTH
  $result = Reset-LocalUserAccount $serviceAccountUserName $serviceAccountPassword
  if ( $result -ne 0 ) { return $result }
  $argList = @(
    'config'
    '"{0}"' -f $serviceName
    'obj= ".\{0}"' -f $serviceAccountUserName
    'password= "{0}"' -f (ConvertTo-String $serviceAccountPassword)
  )
  $result = Start-Program $SC $argList
  return $result
}

# Exit if session isn't elevated
if ( -not (Test-Elevation) ) {
  Write-Error (Get-MessageDescription $ERROR_ELEVATION_REQUIRED -asError)
  exit $ERROR_ELEVATION_REQUIRED
}

# Get path to executable
$SC = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "sc.exe"

# Terminate script if we can't find an executable
$SC | Foreach-Object {
  if ( -not (Test-Path $_) ) {
    Write-Error (Get-MessageDescription $ERROR_FILE_NOT_FOUND -asError)
    exit $ERROR_FILE_NOT_FOUND
  }
}

$ExitCode = ResetServiceAccountPassword $ServiceAccountUserName "syncthing"
if ( $ExitCode -ne 0 ) {
  Write-Error (Get-MessageDescription $ExitCode -asError)
}
exit $ExitCode
