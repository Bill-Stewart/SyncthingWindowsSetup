; Syncthing.iss - Syncthing Windows Setup
; Written by Bill Stewart (bstewart AT iname.com) for Syncthing

; Windows Inno Setup installer for Syncthing (https://syncthing.net/)
; * see LICENSE for license
; * See README.md for documentation
; * See building.md for build/localization info

#if Ver < EncodeVer(6,0,0,0)
  #error This script requires Inno Setup 6 or later
#endif

#define AppName "Syncthing"
#define AppVersion GetStringFileInfo("bin\amd64\syncthing.exe",PRODUCT_VERSION)
#define AppPublisher "Syncthing Foundation"
#define AppURL "https://syncthing.net/"
#define ServiceName "syncthing"
#define ServiceStopTimeout "10000"
#define DefaultListenAddress "127.0.0.1"
#define DefaultListenPort "8384"
#define ConfigurationPageName "ConfigurationPage"
#define ScriptNameConfigSyncthingService "ConfigSyncthingService.js"
#define ScriptNameStartSyncthing "StartSyncthing.js"
#define ScriptNameStopSyncthing "StopSyncthing.js"
#define ScriptNameSyncthingFirewallRule "SyncthingFirewallRule.js"
#define ScriptNameSyncthingLogonTask "SyncthingLogonTask.js"

[Setup]
AppId={{1EEA2B6F-FD76-47D7-B74C-03E14CF043F9}
AppName={#AppName}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
ArchitecturesInstallIn64BitMode=x64
CloseApplications=yes
CloseApplicationsFilter=*.exe,*.pdf
RestartApplications=yes
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableWelcomePage=yes
AllowNoIcons=yes
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=.
OutputBaseFilename=syncthing-{#AppVersion}-setup
Compression=lzma2/max
SolidCompression=yes
ShowTasksTreeLines=yes
WizardStyle=modern
WizardSizePercent=120
UninstallFilesDir={app}\uninstall
UninstallDisplayIcon={app}\syncthing.exe,0
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoVersion={#AppVersion}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"

; See building.md file for localization details
#define protected LocalizationFile AddBackslash(SourcePath) + "Localization.ini"
#define protected NumLanguages 1
#dim    protected Languages[NumLanguages]
#define protected Languages[0] "en"

[Files]
; Scripts (use preprocessor to support multiple languages)
#define protected i 0
#sub LocalizeScriptNames
#define protected Language Languages[i]
#define protected ScriptNameFirewallRule  ReadIni(LocalizationFile, Language, "ScriptNameSyncthingFirewallRule")
#define protected ScriptNameConfigService ReadIni(LocalizationFile, Language, "ScriptNameConfigSyncthingService")
#define protected ScriptNameLogonTask     ReadIni(LocalizationFile, Language, "ScriptNameSyncthingLogonTask")
#define protected ScriptNameStart         ReadIni(LocalizationFile, Language, "ScriptNameStartSyncthing")
#define protected ScriptNameStop          ReadIni(LocalizationFile, Language, "ScriptNameStopSyncthing")
Source: "{#ScriptNameFirewallRule}";  DestDir: "{app}"; DestName: "{#ScriptNameSyncthingFirewallRule}";  Flags: ignoreversion; Languages: {#Language}
Source: "{#ScriptNameConfigService}"; DestDir: "{app}"; DestName: "{#ScriptNameConfigSyncthingService}"; Flags: ignoreversion; Languages: {#Language}; Check: IsAdminInstallMode()
Source: "{#ScriptNameLogonTask}";     DestDir: "{app}"; DestName: "{#ScriptNameSyncthingLogonTask}";     Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStart}";         DestDir: "{app}"; DestName: "{#ScriptNameStartSyncthing}";         Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStop}";          DestDir: "{app}"; DestName: "{#ScriptNameStopSyncthing}";          Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
#endsub
#for { i = 0; i < NumLanguages; i++ } LocalizeScriptNames
; General files
Source: "redist\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs
; 64-bit binaries
Source: "bin\amd64\syncthing.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: "nssm\amd64\nssm.exe";     DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode() and IsAdminInstallMode()
; 32-bit binaries
Source: "bin\386\syncthing.exe";   DestDir: "{app}"; Flags: ignoreversion solidbreak; Check: not Is64BitInstallMode()
Source: "nssm\386\nssm.exe";       DestDir: "{app}"; Flags: ignoreversion;            Check: (not Is64BitInstallMode()) and IsAdminInstallMode()

[Registry]
; non-admin only - registry values for StartSyncthing.js
Root: HKA; Subkey: "SOFTWARE\Syncthing";                                                                                                               Flags: uninsdeletekeyifempty; Check: not IsAdminInstallMode()
Root: HKA; Subkey: "SOFTWARE\Syncthing"; ValueType: string; ValueName: "allowautoupgrade";  ValueData: "{code:GetAllowAutoUpgrade}";                   Flags: uninsdeletevalue;      Check: not IsAdminInstallMode()
Root: HKA; Subkey: "SOFTWARE\Syncthing"; ValueType: string; ValueName: "ConfigPageAddress"; ValueData: "{code:GetListenAddress}:{code:GetListenPort}"; Flags: uninsdeletevalue;      Check: not IsAdminInstallMode()

; General notes on use of cscript.exe vs. wscript.exe:
; * Use cscript.exe for hidden commanads (so error doesn't block execution)
; * Use wscript.exe for interactive commands

[Icons]
; both admin and non-admin
Name: "{group}\{cm:ShortcutNameFAQ}";               Filename: "{app}\extra\FAQ.pdf"
Name: "{group}\{cm:ShortcutNameGettingStarted}";    Filename: "{app}\extra\Getting-Started.pdf"
Name: "{group}\{cm:ShortcutNameConfigurationPage}"; Filename: "{app}\{#ConfigurationPageName}.url"; Comment: "{cm:ShortcutNameConfigurationPageComment}"; IconFilename: "{app}\syncthing.exe"
; admin only - configure service
Name: "{group}\{cm:ShortcutNameConfigureService}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameConfigSyncthingService}"""; Comment: "{cm:ShortcutNameConfigureServiceComment}"; IconFilename: "{app}\nssm.exe"; Flags: excludefromshowinnewinstall; Check: IsAdminInstallMode()
; non-admin only - start and stop shortcuts
Name: "{group}\{cm:ShortcutNameStartSyncthing}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameStartSyncthing}"""; Comment: "{cm:ShortcutNameStartSyncthingComment}"; IconFilename: "{app}\syncthing.exe"; Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameStopSyncthing}";  Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameStopSyncthing}""";  Comment: "{cm:ShortcutNameStopSyncthingComment}";  IconFilename: "{app}\syncthing.exe"; Check: not IsAdminInstallMode()

[INI]
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "URL";       String: "https://{code:GetListenAddress}:{code:GetListenPort}"
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "IconFile";  String: "{app}\syncthing.exe"
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"

[Tasks]
Name: allowautoupgrade; Description: "{cm:TasksAllowAutoUpgradeDescription}"; Check: not ServiceExists()

[Run]
; admin only - configure install directory permissions and create firewall rule
Filename: "{sys}\icacls.exe";  Parameters: """{app}"" /grant ""*S-1-5-19:(OI)(CI)M"" /t";                            StatusMsg: "{cm:RunStatusMsg}"; Flags: runhidden; Check: IsAdminInstallMode()
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create /elevated /silent"; StatusMsg: "{cm:RunStatusMsg}"; Flags: runhidden; Check: IsAdminInstallMode()
; non-admin only - create or update per-user logon task
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /create /silent"; Flags: runhidden; StatusMsg: "{cm:RunStatusMsg}"; Check: not IsAdminInstallMode()
; postinstall - admin - allow start service when Setup completes
Filename: "{app}\nssm.exe"; Parameters: "start ""{#ServiceName}"""; Description: "{cm:RunPostInstallStartServiceDescription}"; Flags: runascurrentuser runhidden nowait postinstall; Check: IsAdmininstallMode() and StartAfterInstall() and ServiceExists() and (not ServiceRunning())
; postinstall - non-admin - allow start as current user when Setup completes
Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameStartSyncthing}"""; Description: "{cm:RunPostInstallStartDescription}"; Flags: nowait postinstall; Check: (not IsAdminInstallMode()) and StartAfterInstall() and FirewallRuleExists()

[UninstallRun]
; admin only - remove firewall rule
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /remove /elevated /silent"; Flags: runhidden; RunOnceId: removefwrule; Check: IsAdminInstallMode()
; non-admin only - remove per-user logon task
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /remove /silent"; Flags: runhidden; RunOnceId: removelogontask; Check: not IsAdminInstallMode()

[UninstallDelete]
Type: files; Name: "{app}\{#ConfigurationPageName}.url"

[Code]
const
  ERROR_MORE_DATA      = 234;
  SC_MANAGER_CONNECT   = 1;
  SERVICE_QUERY_STATUS = 4;
  SERVICE_RUNNING      = 4;

type
  TServiceStatus = record
    dwServiceType:             DWORD;
    dwCurrentState:            DWORD;
    dwControlsAccepted:        DWORD;
    dwWin32ExitCode:           DWORD;
    dwServiceSpecificExitCode: DWORD;
    dwCheckPoint:              DWORD;
    dwWaitHint:                DWORD;
  end;

var
  NetConfigPage: TInputQueryWizardPage;  // Custom wizard page
  ListenAddress, ListenPort: string;     // GUI configuration page listen address and port

// Windows API functions
function GetUserNameExW(NameFormat: Integer; lpNameBuffer: string; var nSize: DWORD): Boolean;
  external 'GetUserNameExW@secur32.dll stdcall';
function OpenSCManager(lpMachineName: string; lpDatabaseName: string; dwDesiredAccess: DWORD): THandle;
  external 'OpenSCManagerW@advapi32.dll stdcall';
function OpenService(hSCManager: THandle; lpServiceName: string; dwDesiredAccess: DWORD): THandle;
  external 'OpenServiceW@advapi32.dll stdcall';
function QueryServiceStatus(hService: THandle; out lpServiceStatus: TServiceStatus): BOOL;
  external 'QueryServiceStatus@advapi32.dll stdcall';
function CloseServiceHandle(hSCObject: THandle): BOOL;
  external 'CloseServiceHandle@advapi32.dll stdcall';

function GetFullUserName(): string;
var
  NumChars: DWORD;
  OutStr: string;
begin
  result := '';
  try
    NumChars := 0;
    // NameFormat = 2: NameSamCompatible (i.e., authority\username)
    // First call: GetUserNameExW should return false and DLLGetLastError()
    // should return ERROR_MORE_DATA (234); NumChars will contain # chars
    // needed, including null terminator
    if (not GetUserNameExW(2, '', NumChars)) and (DLLGetLastError() = ERROR_MORE_DATA) then
    begin
      SetLength(OutStr, NumChars);
      if GetUserNameExW(2, OutStr, NumChars) then
        // Omit null terminator from result
        result := Copy(OutStr, 1, NumChars);
    end;
  except
  end;
end;

function ServiceExists(): Boolean;
var
  Manager, Service: THandle;
  Status: TServiceStatus;
begin
  result := false;
  Manager := OpenSCManager('', '', SC_MANAGER_CONNECT);
  if Manager <> 0 then
  try
    Service := OpenService(Manager, '{#ServiceName}', SERVICE_QUERY_STATUS);
    if Service <> 0 then
    try
      result := QueryServiceStatus(Service, Status);
    finally
      CloseServiceHandle(Service);
    end;
  finally
    CloseServiceHandle(Manager);
  end;
end;

function ServiceRunning(): Boolean;
var
  Manager, Service: THandle;
  Status: TServiceStatus;
begin
  result := false;
  Manager := OpenSCManager('', '', SC_MANAGER_CONNECT);
  if Manager <> 0 then
  try
    Service := OpenService(Manager, '{#ServiceName}', SERVICE_QUERY_STATUS);
    try
      if QueryServiceStatus(Service, Status) then
        result := Status.dwCurrentState = SERVICE_RUNNING;
    finally
      CloseServiceHandle(Service);
    end;
  finally
    CloseServiceHandle(Manager);
  end;
end;

function ParamStrExists(const Param: string): Boolean;
var
  I: Integer;
begin
  result := false;
  for I := 1 to ParamCount do
  begin
    result := CompareText(Param, ParamStr(I)) = 0;
    if result then
      exit;
  end;
end;

function StartAfterInstall(): boolean;
begin
  result := not ParamStrExists('/nostart');
end;

function InitializeSetup(): Boolean;
begin
  result := true;
  // Support /listenaddress and /listenport command line parameters
  ListenAddress := Trim(ExpandConstant('{param:listenaddress|{#DefaultListenAddress}}'));
  ListenPort := Trim(ExpandConstant('{param:listenport|{#DefaultListenPort}}'));
end;

procedure InitializeWizard();
begin
  // Create custom network configuration page
  NetConfigPage := CreateInputQueryPage(wpSelectProgramGroup,
    CustomMessage('NetConfigPageCaption'),
    CustomMessage('NetConfigPageDescription'),
    CustomMessage('NetConfigPageSubCaption'));
  NetConfigPage.Add(FmtMessage(CustomMessage('NetConfigPageItem0'), ['{#DefaultListenAddress}']), false);
  NetConfigPage.Add(FmtMessage(CustomMessage('NetConfigPageItem1'), ['{#DefaultListenPort}']), false);
  NetConfigPage.Values[0] := ListenAddress;
  NetConfigPage.Values[1] := ListenPort;
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  result := false;
  if PageID = NetConfigPage.ID then
  begin
    if IsAdminInstallMode() then
      // Skip network page if service already installed
      result := ServiceExists();
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Port: Integer;
begin
  result := true;
  if CurPageID = NetConfigPage.ID then
  begin
    // Validate listen address (not empty)
    result := Trim(NetConfigPage.Values[0]) <> '';
    if not result then
    begin
      Log(CustomMessage('NetConfigPageItem0Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('NetConfigPageItem0Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := NetConfigPage.Edits[0];
      NetConfigPage.Values[0] := '{#DefaultListenAddress}';
      NetConfigPage.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenAddress := NetConfigPage.Values[0];
    // Validate listen port (not empty)
    result := Trim(NetConfigPage.Values[1]) <> '';
    if not result then
    begin
      Log(CustomMessage('NetConfigPageItem1Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('NetConfigPageItem1Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := NetConfigPage.Edits[1];
      NetConfigPage.Values[1] := '{#DefaultListenPort}';
      NetConfigPage.Edits[1].SelectAll();
      exit;
    end;
    // Validate listen port (>= 1024 and <= 65535)
    Port := StrToIntDef(Trim(NetConfigPage.Values[1]), 0);
    result := (Port >= 1024) and (Port <= 65535);
    if not result then
    begin
      Log(CustomMessage('NetConfigPageItem1NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('NetConfigPageItem1NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := NetConfigPage.Edits[1];
      NetConfigPage.Values[1] := '{#DefaultListenPort}';
      NetConfigPage.Edits[1].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenPort := NetConfigPage.Values[1];
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: string): string;
var
  Info: string;
begin
  Info := '';
  // Show installation mode
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoInstallInfo') + NewLine
    + Space;
  if IsAdminInstallMode() then
    Info := Info + CustomMessage('ReadyMemoInstallAdmin')
  else
    Info := Info + FmtMessage(CustomMessage('ReadyMemoInstallCurrentUser'), [GetFullUserName()]);
  if MemoUserInfoInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoUserInfoInfo;
  end;
  if MemoDirInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoDirInfo;
  end;
  if MemoTypeInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoTypeInfo;
  end;
  if MemoComponentsInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoComponentsInfo;
  end;
  if MemoGroupInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoGroupInfo;
  end;
  // Show network configuration if service doesn't exist
  if not ServiceExists() then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + CustomMessage('ReadyMemoNetConfigInfo') + NewLine
      + Space + CustomMessage('ReadyMemoNetConfigItem0') + ' ' + ListenAddress + NewLine
      + Space + CustomMessage('ReadyMemoNetConfigItem1') + ' ' + ListenPort;
  end;
  if MemoTasksInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoTasksInfo;
  end;
  result := Info;
end;

// String parameter required for Check functions
function GetAllowAutoUpgrade(Param: string): string;
begin
  if WizardIsTaskSelected('allowautoupgrade') then
    result := 'true'
  else
    result := 'false';
end;

// String parameter required for Check functions
function GetListenAddress(Param: string): string;
begin
  result := ListenAddress;
end;

// String parameter required for Check functions
function GetListenPort(Param: string): string;
begin
  result := ListenPort;
end;

function ExecEx(const FileName, Params: string; const Hide: Boolean): Integer;
var
  ShowCmd: Integer;
  OK: Boolean;
begin
  if Hide then
    ShowCmd := SW_HIDE
  else
    ShowCmd := SW_SHOWNORMAL;
  OK := Exec(FileName,        // Filename
    Params,                   // Params
    ExpandConstant('{app}'),  // WorkingDir
    ShowCmd,                  // ShowCmd
    ewWaitUntilTerminated,    // TExecWait
    result);                  // ResultCode
  Log(Format('Exec: "%s" %s', [FileName, Params]));
  if OK then
    Log('Exec exit code: ' + IntToStr(result))
  else
    Log('Exec failed: ' + SysErrorMessage(result)
       + ' (' + IntToStr(result) + ')');
end;

function FirewallRuleExists(): Boolean;
begin
  result := ExecEx(ExpandConstant('{sys}\cscript.exe'),
    ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /test'),
    true) = 0;
end;

procedure InstallService();
var
  FileName, Params: string;
begin
  if not ServiceExists() then
  begin
    FileName := ExpandConstant('{app}\nssm.exe');
    // Install
    Params := ExpandConstant('install "{#ServiceName}" "{app}\syncthing.exe"');
    ExecEx(FileName, Params, true);
    // set AppParameters
    Params := 'set "{#ServiceName}" AppParameters "--no-browser --no-restart';
    if not WizardIsTaskSelected('allowautoupgrade') then
      Params := Params + ' --no-upgrade';
    Params := Params + ' --gui-address=\"' + GetListenAddress('') + ':' + GetListenPort('') + '\""';
    ExecEx(FileName, Params, true);
    // set DisplayName
    Params := ExpandConstant('set "{#ServiceName}" DisplayName "{cm:ServiceDisplayName}"');
    ExecEx(FileName, Params, true);
    // set Description
    Params := ExpandConstant('set "{#ServiceName}" Description "{cm:ServiceDescription}"');
    ExecEx(FileName, Params, true);
    // set ObjectName
    Params := 'set "{#ServiceName}" ObjectName "NT AUTHORITY\LOCAL SERVICE"';
    ExecEx(FileName, Params, true);
    // set AppPriority
    Params := 'set "{#ServiceName}" AppPriority BELOW_NORMAL_PRIORITY_CLASS';
    ExecEx(FileName, Params, true);
    // set Start
    Params := 'set "{#ServiceName}" Start SERVICE_DELAYED_AUTO_START';
    ExecEx(Filename, Params, true);
    // set AppNoConsole
    Params := 'set "{#ServiceName}" AppNoConsole 1';
    ExecEx(FileName, Params, true);
    // set AppStopMethodConsole
    Params := 'set "{#ServiceName}" AppStopMethodConsole {#ServiceStopTimeout}';
    ExecEx(FileName, Params, true);
    // set AppStopMethodWindow
    Params := 'set "{#ServiceName}" AppStopMethodWindow {#ServiceStopTimeout}';
    ExecEx(FileName, Params, true);
    // set AppStopMethodThreads
    Params := 'set "{#ServiceName}" AppStopMethodThreads {#ServiceStopTimeout}';
    ExecEx(FileName, Params, true);
    // set AppExit Default Exit
    Params := 'set "{#ServiceName}" AppExit Default Exit';
    ExecEx(FileName, Params, true);
    // set AppExit 0 Exit
    Params := 'set "{#ServiceName}" AppExit 0 Exit';
    ExecEx(FileName, Params, true);
    // set AppExit 3 Restart
    Params := 'set "{#ServiceName}" AppExit 3 Restart';
    ExecEx(FileName, Params, true);
    // set AppExit 4 Restart
    Params := 'set "{#ServiceName}" AppExit 4 Restart';
    ExecEx(FileName, Params, true);
    // set AppEnvironmentExtra
    Params := 'set "{#ServiceName}" AppEnvironmentExtra STNODEFAULTFOLDER=1';
    ExecEx(FileName, Params, true);
  end;
end;

procedure StopService();
begin
  if ServiceExists() then
    ExecEx(ExpandConstant('{app}\nssm.exe'), 'stop "{#ServiceName}"', true);
end;

procedure RemoveService();
begin
  if ServiceExists() then
    ExecEx(ExpandConstant('{app}\nssm.exe'), 'remove "{#ServiceName}" confirm', true);
end;

function PrepareToInstall(var NeedsRestart: Boolean): string;
begin
  result := '';
  if IsAdminInstallMode() then
  begin
    if ServiceRunning() then
      StopService();
  end
  else
  begin
    ExecEx(ExpandConstant('{sys}\cscript.exe'),
      ExpandConstant('"{app}\{#ScriptNameStopSyncthing}" /silent'),
      true);
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if IsAdminInstallMode() then
    begin
      if not ServiceExists() then
        InstallService();
    end
    else
    begin
      if not WizardSilent() then
      begin
        if not FirewallRuleExists() then
        begin
          // Prompt to create Windows Firewall rule
          ExecEx(ExpandConstant('{sys}\wscript.exe'),
            ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /create'),
            false);
        end;
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if IsAdminInstallMode() and ServiceExists() then
    begin
      StopService();
      RemoveService();
    end;
    if not IsAdminInstallMode() then
    begin
      ExecEx(ExpandConstant('{sys}\cscript.exe'),
        ExpandConstant('"{app}\{#ScriptNameStopSyncthing}" /silent'),
        true);
      if not UninstallSilent() then
      begin
        if FirewallRuleExists() then
        begin
          // Prompt to remove Windows Firewall rule
          ExecEx(ExpandConstant('{sys}\wscript.exe'),
            ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /remove'),
            false);
        end;
      end;
    end;
  end;
end;
