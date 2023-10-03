#requires -version 2

<#
.SYNOPSIS
Installs, resets, or removes the Syncthing service.

.DESCRIPTION
Installs, resets, or removes the Syncthing service.

.PARAMETER Install
Creates or resets the local service user account, grants the service user account logon rights to the local service user account, and installs or resets the Syncthing service.

.PARAMETER Remove
Disables the local service user account, removes its service logon rights, and stops and removes the Syncthing service.

.PARAMETER ServiceAccountUserName
Specifies the username of the local service user account.

.PARAMETER ServiceName
Specifies the name for the service.

.PARAMETER ServiceAccountDescription
Specifies the description of the local service user account.

.PARAMETER ServiceDisplayName
Specifies the display name for the service.

.PARAMETER ServiceDescription
Specifies the description for the service.

.PARAMETER ServiceStartupType
Specifies the startup type for the service. Must be one of: 'auto', 'delayed-auto', 'demand', or 'disabled'.

.PARAMETER ServiceShutdownTimeout
Specifies the number of milliseconds to wait at service shutdown.
#>

[CmdletBinding()]
param(
  [Parameter(ParameterSetName = "Install",Position = 0,Mandatory)]
  [Switch]
  $Install,

  [Parameter(ParameterSetName = "Remove",Position = 0,Mandatory)]
  [Switch]
  $Remove,

  [Parameter(ParameterSetName = "Install",Position = 1,Mandatory)]
  [Parameter(ParameterSetName = "Remove",Position = 1,Mandatory)]
  [String]
  $ServiceAccountUserName,

  [Parameter(ParameterSetName = "Install",Position = 2,Mandatory)]
  [Parameter(ParameterSetName = "Remove",Position = 2,Mandatory)]
  [String]
  $ServiceName,

  [Parameter(ParameterSetName = "Install")]
  [String]
  $ServiceAccountDescription,

  [Parameter(ParameterSetName = "Install")]
  [String]
  $ServiceDisplayName,

  [Parameter(ParameterSetName = "Install")]
  [String]
  $ServiceDescription,

  [Parameter(ParameterSetName = "Install",Mandatory)]
  [ValidateSet("auto","delayed-auto","demand","disabled")]
  [String]
  $ServiceStartupType,

  [Parameter(ParameterSetName = "Install")]
  [String]
  $ServiceShutdownTimeout
)

Add-Type -TypeDefinition @'
// For the local user management functions, we'll use PowerShell "wrapper"
// functions to call the Win32 APIs
namespace A5DE5EC805564623B4D67E72D5AC077E {
  using System;
  using System.Runtime.InteropServices;

  public class NetApi32 : IDisposable {
    // [A5DE5EC805564623B4D67E72D5AC077E.NetApi32+USER_INFO_2]
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

    // [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserAdd()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetUserAdd(
      string   servername,
      uint     level,
      IntPtr   buf,
      out uint parm_err);

    // [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserGetInfo()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetUserGetInfo(
      string     servername,
      string     username,
      uint       level,
      out IntPtr bufptr);

    // [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserSetInfo()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetUserSetInfo(
      string   servername,
      string   username,
      uint     level,
      IntPtr   bufptr,
      out uint parm_err);

    // [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetApiBufferFree()
    [DllImport("netapi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern uint NetApiBufferFree(IntPtr Buffer);

    public void Dispose() {
    }
  }
}

// Special thanks to Tony Pombo (UserRights.psm1) for the base code used for
// grant/revoke user rights (modifications by yours truly to return exit codes
// instead of throwing exceptions, along with some other changes)
namespace AC19F00870F64562942F69277A3AACB8 {
  using System;
  using System.ComponentModel;
  using System.Runtime.InteropServices;
  using System.Security;
  using System.Security.Principal;
  using LSA_HANDLE = System.IntPtr;

  // [AC19F00870F64562942F69277A3AACB8.SecurityRights]
  public enum SecurityRights {
    SeTrustedCredManAccessPrivilege,            // Access Credential Manager as a trusted caller
    SeNetworkLogonRight,                        // Access this computer from the network
    SeTcbPrivilege,                             // Act as part of the operating system
    SeMachineAccountPrivilege,                  // Add workstations to domain
    SeIncreaseQuotaPrivilege,                   // Adjust memory quotas for a process
    SeInteractiveLogonRight,                    // Allow log on locally
    SeRemoteInteractiveLogonRight,              // Allow log on through Remote Desktop Services
    SeBackupPrivilege,                          // Back up files and directories
    SeChangeNotifyPrivilege,                    // Bypass traverse checking
    SeSystemtimePrivilege,                      // Change the system time
    SeTimeZonePrivilege,                        // Change the time zone
    SeCreatePagefilePrivilege,                  // Create a pagefile
    SeCreateTokenPrivilege,                     // Create a token object
    SeCreateGlobalPrivilege,                    // Create global objects
    SeCreatePermanentPrivilege,                 // Create permanent shared objects
    SeCreateSymbolicLinkPrivilege,              // Create symbolic links
    SeDebugPrivilege,                           // Debug programs
    SeDenyNetworkLogonRight,                    // Deny access this computer from the network
    SeDenyBatchLogonRight,                      // Deny log on as a batch job
    SeDenyServiceLogonRight,                    // Deny log on as a service
    SeDenyInteractiveLogonRight,                // Deny log on locally
    SeDenyRemoteInteractiveLogonRight,          // Deny log on through Remote Desktop Services
    SeEnableDelegationPrivilege,                // Enable computer and user accounts to be trusted for delegation
    SeRemoteShutdownPrivilege,                  // Force shutdown from a remote system
    SeAuditPrivilege,                           // Generate security audits
    SeImpersonatePrivilege,                     // Impersonate a client after authentication
    SeIncreaseWorkingSetPrivilege,              // Increase a process working set
    SeIncreaseBasePriorityPrivilege,            // Increase scheduling priority
    SeLoadDriverPrivilege,                      // Load and unload device drivers
    SeLockMemoryPrivilege,                      // Lock pages in memory
    SeBatchLogonRight,                          // Log on as a batch job
    SeServiceLogonRight,                        // Log on as a service
    SeSecurityPrivilege,                        // Manage auditing and security log
    SeRelabelPrivilege,                         // Modify an object label
    SeSystemEnvironmentPrivilege,               // Modify firmware environment values
    SeDelegateSessionUserImpersonatePrivilege,  // Obtain an impersonation token for another user in the same session
    SeManageVolumePrivilege,                    // Perform volume maintenance tasks
    SeProfileSingleProcessPrivilege,            // Profile single process
    SeSystemProfilePrivilege,                   // Profile system performance
    SeUnsolicitedInputPrivilege,                // Read unsolicited input from a terminal device
    SeUndockPrivilege,                          // Remove computer from docking station
    SeAssignPrimaryTokenPrivilege,              // Replace a process level token
    SeRestorePrivilege,                         // Restore files and directories
    SeShutdownPrivilege,                        // Shut down the system
    SeSyncAgentPrivilege,                       // Synchronize directory service data
    SeTakeOwnershipPrivilege                    // Take ownership of files or other objects
  }

  [StructLayout(LayoutKind.Sequential)]
  struct LSA_OBJECT_ATTRIBUTES {
    internal int    Length;
    internal IntPtr RootDirectory;
    internal IntPtr ObjectName;
    internal int    Attributes;
    internal IntPtr SecurityDescriptor;
    internal IntPtr SecurityQualityOfService;
  }

  [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
  struct LSA_UNICODE_STRING {
    internal ushort Length;
    internal ushort MaximumLength;
    [MarshalAs(UnmanagedType.LPWStr)]
    internal string Buffer;
  }

  internal sealed class Win32Security {
    [DllImport("advapi32", CharSet = CharSet.Unicode, SetLastError = true)]
    internal static extern uint LsaOpenPolicy(
      LSA_UNICODE_STRING[]      SystemName,
      ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
      int                       AccessMask,
      out IntPtr                PolicyHandle);

    [DllImport("advapi32", CharSet = CharSet.Unicode, SetLastError = true)]
    internal static extern uint LsaAddAccountRights(
      LSA_HANDLE           PolicyHandle,
      IntPtr               pSID,
      LSA_UNICODE_STRING[] UserRights,
      int                  CountOfRights);

    [DllImport("advapi32", CharSet = CharSet.Unicode, SetLastError = true)]
    internal static extern uint LsaRemoveAccountRights(
      LSA_HANDLE           PolicyHandle,
      IntPtr               pSID,
      bool                 AllRights,
      LSA_UNICODE_STRING[] UserRights,
      int                  CountOfRights);

    [DllImport("advapi32")]
    internal static extern int LsaClose(IntPtr PolicyHandle);

    [DllImport("advapi32")]
    internal static extern int LsaFreeMemory(IntPtr Buffer);
  }

  internal sealed class Sid : IDisposable {
    public IntPtr pSid = IntPtr.Zero;

    public SecurityIdentifier sid = null;

    public Sid(string account) {
      try {
        sid = new SecurityIdentifier(account);
      }
      catch {
        sid = (SecurityIdentifier)(new NTAccount(account)).Translate(typeof(SecurityIdentifier));
      }
      Byte[] buffer = new Byte[sid.BinaryLength];
      sid.GetBinaryForm(buffer, 0);
      pSid = Marshal.AllocHGlobal(sid.BinaryLength);
      Marshal.Copy(buffer, 0, pSid, sid.BinaryLength);
    }

    public void Dispose() {
      if ( pSid != IntPtr.Zero ) {
        Marshal.FreeHGlobal(pSid);
        pSid = IntPtr.Zero;
      }
      GC.SuppressFinalize(this);
    }

    ~Sid() {
      Dispose();
    }
  }

  public sealed class LocalSecurityAuthority : IDisposable {
    private const int POLICY_ALL_ACCESS = 0xF0FFF;

    IntPtr LsaHandle;

    public uint Connect(string systemName) {
      LSA_OBJECT_ATTRIBUTES lsaAttr;
      lsaAttr.RootDirectory = IntPtr.Zero;
      lsaAttr.ObjectName = IntPtr.Zero;
      lsaAttr.Attributes = 0;
      lsaAttr.SecurityDescriptor = IntPtr.Zero;
      lsaAttr.SecurityQualityOfService = IntPtr.Zero;
      lsaAttr.Length = Marshal.SizeOf(typeof(LSA_OBJECT_ATTRIBUTES));
      LsaHandle = IntPtr.Zero;
      LSA_UNICODE_STRING[] system = null;
      if ( systemName != null ) {
        system = new LSA_UNICODE_STRING[1];
        system[0] = InitLsaString(systemName);
      }
      return Win32Security.LsaOpenPolicy(system, ref lsaAttr, POLICY_ALL_ACCESS, out LsaHandle);
    }

    public uint AddRights(string account, SecurityRights privilege) {
      uint result = 0;
      using ( Sid sid = new Sid(account) ) {
        LSA_UNICODE_STRING[] privileges = new LSA_UNICODE_STRING[1];
        privileges[0] = InitLsaString(privilege.ToString());
        result = Win32Security.LsaAddAccountRights(LsaHandle, sid.pSid, privileges, 1);
      }
      return result;
    }

    public uint RemoveRights(string account, SecurityRights privilege) {
      uint result = 0;
      using ( Sid sid = new Sid(account) ) {
        LSA_UNICODE_STRING[] privileges = new LSA_UNICODE_STRING[1];
        privileges[0] = InitLsaString(privilege.ToString());
        result = Win32Security.LsaRemoveAccountRights(LsaHandle, sid.pSid, false, privileges, 1);
      }
      return result;
    }

    public void Dispose() {
      if ( LsaHandle != IntPtr.Zero ) {
        Win32Security.LsaClose(LsaHandle);
        LsaHandle = IntPtr.Zero;
      }
      GC.SuppressFinalize(this);
    }

    ~LocalSecurityAuthority() {
      Dispose();
    }

    static LSA_UNICODE_STRING InitLsaString(string s) {
      LSA_UNICODE_STRING lsaStr = new LSA_UNICODE_STRING();
      // Must be less than 32KB
      if ( s.Length < 0x7fff ) {
        lsaStr.Buffer = s;
        lsaStr.Length = (ushort)(s.Length * sizeof(char));
        lsaStr.MaximumLength = (ushort)(lsaStr.Length + sizeof(char));
      }
      return lsaStr;
    }
  }
}
'@

$ERROR_FILE_NOT_FOUND     = 2
$ERROR_CANNOT_MAKE        = 82
$ERROR_ELEVATION_REQUIRED = 740
$RANDOM_PASSWORD_LENGTH   = 127
$USER_PRIV_USER           = 1
$UF_SCRIPT                = 0x00001
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
# Creates a local user account; returns 0 for success, non-zero for failure
function New-LocalUserAccount {
  param(
    [String]
    $accountName,

    [String]
    $accountDescription,

    [Security.SecureString]
    $password
  )
  $userInfo2 = New-Object A5DE5EC805564623B4D67E72D5AC077E.NetApi32+USER_INFO_2
  $userInfo2.usri2_name = $accountName
  $userInfo2.usri2_password = (ConvertTo-String $password)

  # These are required when creating a new account
  $userInfo2.usri2_priv = $USER_PRIV_USER
  $userInfo2.usri2_flags = $UF_SCRIPT
  $userInfo2.usri2_acct_expires = [UInt32]::MaxValue
  $userInfo2.usri2_max_storage = [UInt32]::MaxValue

  # Set full name and description
  $userInfo2.usri2_full_name = ""
  $userInfo2.usri2_comment = $accountDescription

  # Set "Password never expires"
  $userInfo2.usri2_flags = $userInfo2.usri2_flags -bor $UF_DONT_EXPIRE_PASSWD

  try {
    # Allocate memory for unmanaged USER_INFO_2 buffer
    $pUserInfo2 = [Runtime.InteropServices.Marshal]::AllocHGlobal([Runtime.InteropServices.Marshal]::SizeOf($userInfo2))
    # Copy the managed object to it
    [Runtime.InteropServices.Marshal]::StructureToPtr($userInfo2,$puserInfo2,$false)
    $parmErr = 0
    [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserAdd(
      $null,           # servername
      2,               # level
      $pUserInfo2,     # buf
      [Ref] $parmErr)  # parm_err
  }
  finally {
    # Free the unmanaged buffer
    [Runtime.InteropServices.Marshal]::FreeHGlobal($pUserInfo2)
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
    $result = [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserGetInfo(
      $null,              # servername
      $accountName,       # username
      2,                  # level
      [Ref] $pUserInfo2)  # bufptr
    if ( $result -eq 0 ) {
      # Copy the unmanaged buffer to the managed object
      # Value property is required because it's a [Ref] parameter
      $userInfo2.Value = [Runtime.InteropServices.Marshal]::PtrToStructure($pUserInfo2,
        [Type] [A5DE5EC805564623B4D67E72D5AC077E.NetApi32+USER_INFO_2])
    }
  }
  finally {
    if ( $pUserInfo2 -ne [IntPtr]::Zero ) {
      # Free the unmanaged buffer
      [Void] [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetApiBufferFree($pUserInfo2)
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
    [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserSetInfo(
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

# P/Invoke
# Disables a local user account; returns 0 for success, non-zero for failure
function Disable-LocalUserAccount {
  param(
    [String]
    $accountName
  )
  $userInfo2 = $null
  $result = Invoke-NetUserGetInfo $accountName ([Ref] $userInfo2)
  if ( $result -ne 0 ) {
    return $result
  }
  if ( ($userInfo2.usri2_flags -band $UF_ACCOUNTDISABLE) -ne 0 ) {
    # Account is already disabled
    return 0
  }
  # Disable if enabled
  $userInfo2.usri2_flags = $userInfo2.usri2_flags -bor $UF_ACCOUNTDISABLE
  # Do not change logon hours
  $userInfo2.usri2_logon_hours = [IntPtr]::Zero
  try {
    # Allocate memory for unmanaged USER_INFO_2 buffer
    $pUserInfo2 = [Runtime.InteropServices.Marshal]::AllocHGlobal([Runtime.InteropServices.Marshal]::SizeOf($userInfo2))
    # Copy the managed object to it
    [Runtime.InteropServices.Marshal]::StructureToPtr($userInfo2,$pUserInfo2,$false)
    $parmErr = 0
    [A5DE5EC805564623B4D67E72D5AC077E.NetApi32]::NetUserSetInfo(
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

# Returns $true if local user account exists, or $false otherwise
function Test-LocalUserAccount {
  param(
    [String]
    $accountName
  )
  $userInfo2 = $null
  (Invoke-NetUserGetInfo $accountName ([Ref] $userInfo2)) -eq 0
}

# P/Invoke
# Grants user right(s) to a local user account; returns 0 for success, non-zero
# for failure
function Grant-UserRight {
  param(
    [String]
    $accountName,

    [AC19F00870F64562942F69277A3AACB8.SecurityRights]
    $rights
  )
  $result = 0
  $localSA = New-Object AC19F00870F64562942F69277A3AACB8.LocalSecurityAuthority
  $result = $localSA.Connect("")
  if ( $result -eq 0 ) {
    $result = $localSA.AddRights($accountName,$rights)
  }
  return $result
}

# P/Invoke
# Revokes user right(s) from a local user account; returns 0 for success,
# non-zero for failure
function Revoke-UserRight {
  param(
    [String]
    $accountName,

    [AC19F00870F64562942F69277A3AACB8.SecurityRights]
    $rights
  )
  $result = 0
  $localSA = New-Object AC19F00870F64562942F69277A3AACB8.LocalSecurityAuthority
  $result = $localSA.Connect("")
  if ( $result -eq 0 ) {
    $result = $localSA.RemoveRights($accountName,$rights)
  }
  return $result
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

# Returns $true if the specified service exists, or $false otherwise
function Test-Service {
  param(
    [String]
    $serviceName
  )
  return $null -ne (Get-Service $serviceName -ErrorAction SilentlyContinue)
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

function InstallService {
  param(
    [String]
    $serviceAccountUserName,

    [String]
    $serviceAccountDescription,

    [String]
    $serviceName,

    [String]
    $serviceDisplayName,

    [String]
    $serviceDescription,

    [String]
    $serviceStartupType,

    [String]
    $serviceShutdownTimeout
  )
  $result = 0
  # Create config directory if it doesn't exist
  if ( -not (Test-Path -LiteralPath $SyncthingConfigPath) ) {
    New-Item $SyncthingConfigPath -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    if ( -not $? ) { return $ERROR_CANNOT_MAKE }
  }
  # Reset permissions for config directory
  $argList = @(
    '"{0}"' -f $SyncthingConfigPath
    '/reset'
    '/t'
  )
  Start-Program $ICACLS $argList | Out-Null
  $argList = @(
    '"{0}"' -f $SyncthingConfigPath
    '/inheritance:r'
    '/grant "*S-1-5-18:(OI)(CI)F"'
    '/grant "*S-1-5-32-544:(OI)(CI)F"'
    '/grant "{0}:(OI)(CI)M"' -f $serviceAccountUserName
  )
  Start-Program $ICACLS $argList | Out-Null
  # Reset "i" attribute for config directory (paradoxically, "+i" means
  # "not content indexed")
  $argList = @(
    '+i "{0}"' -f $SyncthingConfigPath
  )
  Start-Program $ATTRIB $argList | Out-Null
  $argList = @(
    '+i "{0}"' -f (Join-Path $SyncthingConfigPath "*")
    '/s'
    '/d'
  )
  Start-Program $ATTRIB $argList | Out-Null
  $serviceAccountPassword = New-RandomSecureString $RANDOM_PASSWORD_LENGTH
  # Reset service user account if it exists, or create if it doesn't exist
  if ( Test-LocalUserAccount $serviceAccountUserName ) {
    $result = Reset-LocalUserAccount $serviceAccountUserName $serviceAccountPassword
  }
  else {
    $result = New-LocalUserAccount $serviceAccountUserName $serviceAccountDescription $serviceAccountPassword
  }
  if ( $result -ne 0 ) { return $result }
  $result = Grant-UserRight $serviceAccountUserName SeServiceLogonRight
  if ( $result -ne 0 ) { return $result }
  # Install service if not installed
  if ( -not (Test-Service $serviceName) ) {
    $argList = @(
      'create'
      '"{0}"' -f $serviceName
      'binPath= "\"{0}\" run --cwd \"{1}\" --no-log --priority below-normal --restart-if 3,4 --stop-timeout {2} -- \"{3}\" --home=\"{4}\" --no-browser --no-restart"' -f
        $SHAWL,(Split-Path $SYNCTHING -Parent),$serviceShutdownTimeout,$SYNCTHING,$SyncthingConfigPath
      'DisplayName= "{0}"' -f $serviceDisplayName
      'start= {0}' -f $serviceStartupType
      'obj= ".\{0}"' -f $serviceAccountUserName
      'password= "{0}"' -f (ConvertTo-String $serviceAccountPassword)
    )
    $result = Start-Program $SC $argList
    if ( $result -ne 0 ) { return $result }
    # Set service description
    $argList = @(
      'description "{0}"' -f $serviceName
      '"{0}"' -f $serviceDescription
    )
    $result = Start-Program $SC $argList
  }
  return $result
}

function RemoveService {
  param(
    [String]
    $serviceAccountUserName,

    [String]
    $serviceName
  )
  $result = 0
  # Stop and remove service if it exists
  $service = Get-Service $serviceName -ErrorAction SilentlyContinue
  if ( $null -ne $service ) {
    if ( $service.Status -eq [ServiceProcess.ServiceControllerStatus]::Running ) {
      $result = Start-Program $NET "STOP",$serviceName
      if ( $result -ne 0 ) { return $result }
    }
    $result = Start-Program $SC "delete",$serviceName
    if ( $result -ne 0 ) { return $result }
  }
  # Disable user and remove the user right if user exists
  if ( Test-LocalUserAccount $serviceAccountUserName ) {
    $result = Disable-LocalUserAccount $serviceAccountUserName
    if ( $result -eq 0 ) {
      $result = Revoke-UserRight $serviceAccountUserName SeServiceLogonRight
    }
  }
  return $result
}

# Exit if session isn't elevated
if ( -not (Test-Elevation) ) {
  Write-Error (Get-MessageDescription $ERROR_ELEVATION_REQUIRED -asError)
  exit $ERROR_ELEVATION_REQUIRED
}

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent

# Get paths to executables
$ATTRIB = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "attrib.exe"
$ICACLS = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "icacls.exe"
$NET = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "net.exe"
$SC = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::System)) "sc.exe"
$SHAWL = Join-Path $ScriptPath "shawl.exe"
$SYNCTHING = Join-Path $ScriptPath "syncthing.exe"

# Terminate script if we can't find an executable
$ATTRIB,$ICACLS,$NET,$SC,$SHAWL,$SYNCTHING | Foreach-Object {
  if ( -not (Test-Path $_) ) {
    Write-Error (Get-MessageDescription $ERROR_FILE_NOT_FOUND -asError)
    exit $ERROR_FILE_NOT_FOUND
  }
}

$CommonAppDataPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::CommonApplicationData)
$SyncthingConfigPath = Join-Path $CommonAppDataPath "Syncthing"

$ExitCode = 0

switch ( $PSCmdlet.ParameterSetName ) {
  "Install" {
    $Params = @{
      "serviceAccountUserName"    = $ServiceAccountUserName
      "serviceName"               = $ServiceName
      "serviceAccountDescription" = $ServiceAccountDescription
      "serviceDisplayName"        = $ServiceDisplayName
      "serviceDescription"        = $ServiceDescription
      "serviceStartupType"        = $ServiceStartupType
      "serviceShutdownTimeout"    = $ServiceShutdownTimeout
    }
    $ExitCode = InstallService @Params
  }
  "Remove" {
    $ExitCode = RemoveService $ServiceAccountUserName $ServiceName
  }
}

exit $ExitCode
