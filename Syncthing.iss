; Syncthing.iss - Syncthing Windows Setup
; Written by Bill Stewart (bstewart AT iname.com) for Syncthing

; Windows Inno Setup installer for Syncthing (https://syncthing.net/)
; * see LICENSE for license
; * See README.md for documentation
; * See building.md for build/localization info

#if Ver < EncodeVer(6,0,0,0)
#error This script requires Inno Setup 6 or later
#endif

#define AppID "{1EEA2B6F-FD76-47D7-B74C-03E14CF043F9}"
#define AppName "Syncthing"
#define AppVersion GetStringFileInfo("bin\amd64\syncthing.exe",PRODUCT_VERSION)
#define AppPublisher "Syncthing Foundation"
#define AppURL "https://syncthing.net/"
#define SetupVersion AppVersion + ".0"
#define ServiceName "syncthing"
#define ServiceShutdownTimeout "10000"
#define DefaultAutoUpgradeInterval "12"
#define DefaultListenAddress "127.0.0.1"
#define DefaultListenPort "8384"
#define DefaultServiceAccountUserName "SyncthingServiceAcct"
#define ConfigurationPageName "ConfigurationPage"
#define ScriptNameConfigSyncthingService "ConfigSyncthingService.js"
#define ScriptNameSetSyncthingConfig "SetSyncthingConfig.js"
#define ScriptNameStartSyncthing "StartSyncthing.js"
#define ScriptNameStopSyncthing "StopSyncthing.js"
#define ScriptNameSyncthingFirewallRule "SyncthingFirewallRule.js"
#define ScriptNameSyncthingLogonTask "SyncthingLogonTask.js"

[Setup]
AppId={{#AppID}
AppName={#AppName}
AppVerName={#AppName}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
ArchitecturesInstallIn64BitMode=x64 arm64
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
UsePreviousTasks=yes
WizardStyle=modern
WizardSizePercent=120
UninstallFilesDir={app}\uninstall
UninstallDisplayIcon={app}\syncthing.exe,0
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion={#SetupVersion}

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"; InfoBeforeFile: "License-en.rtf"

; See building.md file for localization details
#define protected LocalizationFile AddBackslash(SourcePath) + "Localization.ini"
#define protected NumLanguages 1
#dim    protected Languages[NumLanguages]
#define protected Languages[0] "en"

[Files]
; WSH scripts (use preprocessor to support multiple languages)
#define protected i 0
#sub LocalizeWSHScripts
#define protected Language Languages[i]
#define protected ScriptNameSetConfig     ReadIni(LocalizationFile, Language, "ScriptNameSetSyncthingConfig")
#define protected ScriptNameConfigService ReadIni(LocalizationFile, Language, "ScriptNameConfigSyncthingService")
#define protected ScriptNameFirewallRule  ReadIni(LocalizationFile, Language, "ScriptNameSyncthingFirewallRule")
#define protected ScriptNameLogonTask     ReadIni(LocalizationFile, Language, "ScriptNameSyncthingLogonTask")
#define protected ScriptNameStart         ReadIni(LocalizationFile, Language, "ScriptNameStartSyncthing")
#define protected ScriptNameStop          ReadIni(LocalizationFile, Language, "ScriptNameStopSyncthing")
Source: "{#ScriptNameFirewallRule}";  DestDir: "{app}"; DestName: "{#ScriptNameSyncthingFirewallRule}";  Flags: ignoreversion; Languages: {#Language}
Source: "{#ScriptNameSetConfig}";     DestDir: "{app}"; DestName: "{#ScriptNameSetSyncthingConfig}";     Flags: ignoreversion; Languages: {#Language}
Source: "{#ScriptNameConfigService}"; DestDir: "{app}"; DestName: "{#ScriptNameConfigSyncthingService}"; Flags: ignoreversion; Languages: {#Language}; Check: IsAdminInstallMode()
Source: "{#ScriptNameLogonTask}";     DestDir: "{app}"; DestName: "{#ScriptNameSyncthingLogonTask}";     Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStart}";         DestDir: "{app}"; DestName: "{#ScriptNameStartSyncthing}";         Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStop}";          DestDir: "{app}"; DestName: "{#ScriptNameStopSyncthing}";          Flags: ignoreversion; Languages: {#language}; Check: not IsAdminInstallMode()
#endsub
#for { i = 0; i < NumLanguages; i++ } LocalizeWSHScripts
; General files
Source: "redist\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs
; PowerShell service install script
Source: "Install-SyncthingService.ps1"; DestDir: "{app}"; Flags: ignoreversion; Check: IsAdminInstallMode()
; 386 binaries
Source: "bin\386\syncthing.exe";   DestDir: "{app}"; Flags: ignoreversion; Check: not Is64BitInstallMode()
Source: "nssm\386\nssm.exe";       DestDir: "{app}"; Flags: ignoreversion; Check: ((not Is64BitInstallMode()) or (Is64BitInstallMode() and IsARM64())) and IsAdminInstallMode()
Source: "startps\386\startps.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: ((not Is64BitInstallMode()) or (Is64BitInstallMode() and IsARM64())) and IsAdminInstallMode()
; amd64 binaries
Source: "bin\amd64\syncthing.exe";   DestDir: "{app}"; Flags: ignoreversion solidbreak; Check: Is64BitInstallMode() and IsX64()
Source: "nssm\amd64\nssm.exe";       DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode() and IsX64() and IsAdminInstallMode()
Source: "startps\amd64\startps.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode() and IsX64() and IsAdminInstallMode()
; arm64 binaries
Source: "bin\arm64\syncthing.exe";   DestDir: "{app}"; Flags: ignoreversion solidbreak; Check: Is64BitInstallMode() and IsARM64()

[Dirs]
Name: "{autoappdata}\{#AppName}"; Attribs: notcontentindexed; Check: IsAdminInstallMode()

; When to use cscript.exe vs. wscript.exe:
; * Use cscript.exe for hidden scripts (so error doesn't block execution)
; * Use wscript.exe for interactive scripts

[Icons]
; Both admin and non-admin
Name: "{group}\{cm:ShortcutNameConfigurationPage}"; \
  Filename: "{app}\{#ConfigurationPageName}.url"; \
  Comment: "{cm:ShortcutNameConfigurationPageComment}"; \
  IconFilename: "{app}\syncthing.exe"
; Admin: Configure service
Name: "{group}\{cm:ShortcutNameConfigureService}"; \
  Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameConfigSyncthingService}"""; \
  Comment: "{cm:ShortcutNameConfigureServiceComment}"; \
  IconFilename: "{app}\nssm.exe"; \
  Flags: excludefromshowinnewinstall; \
  Check: IsAdminInstallMode()
; Non-admin: Start and stop shortcuts
Name: "{group}\{cm:ShortcutNameStartSyncthing}"; \
  Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameStartSyncthing}"""; \
  Comment: "{cm:ShortcutNameStartSyncthingComment}"; \
  IconFilename: "{app}\syncthing.exe"; \
  Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameStopSyncthing}"; \
  Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameStopSyncthing}"""; \
  Comment: "{cm:ShortcutNameStopSyncthingComment}"; \
  IconFilename: "{app}\syncthing.exe"; \
  Check: not IsAdminInstallMode()

[INI]
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "URL"; \
  String: "https://{code:GetListenAddress}:{code:GetListenPort}"
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "IconFile"; \
  String: "{app}\syncthing.exe"
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "IconIndex"; \
  String: "0"

[Tasks]
; Admin
Name: startatboot; \
  Description: "{cm:TasksStartAtBoot}"; \
  Check: IsAdminInstallMode()
; Non-admin
Name: startatlogon; \
  Description: "{cm:TasksStartAtLogon}"; \
  Check: (not IsAdminInstallMode()) and (not LogonTaskExists())

[Run]
; Admin: Add firewall rule silently
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create /elevated /silent"; \
  Flags: runhidden; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Check: IsAdminInstallMode()
; Non-admin: Prompt to add firewall rule
Filename: "{sys}\wscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create"; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Check: (not IsAdminInstallMode()) and (not FirewallRuleExists()) and (not WizardSilent())
; Non-admin: Create logon task if selected
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /create /silent"; \
  Flags: runhidden; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Tasks: startatlogon
; Admin post-install
Filename: "{app}\nssm.exe"; \
  Parameters: "start ""{#ServiceName}"""; \
  Description: "{cm:RunPostInstallStartServiceDescription}"; \
  Flags: runascurrentuser runhidden nowait postinstall; \
  Check: IsAdmininstallMode() and GetStartAfterInstall() and ServiceExists() and (not ServiceRunning())
; Non-admin post-install
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameStartSyncthing}"" /silent"; \
  Description: "{cm:RunPostInstallStartDescription}"; \
  Flags: runhidden nowait postinstall; \
  Check: (not IsAdminInstallMode()) and GetStartAfterInstall() and FirewallRuleExists()

[UninstallRun]
; Admin: remove firewall rule
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /remove /elevated /silent"; \
  Flags: runhidden; \
  RunOnceId: removefwrule; \
  Check: IsAdminInstallMode()
; Non-admin: remove logon task
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /remove /silent"; \
  Flags: runhidden; \
  RunOnceId: removelogontask; \
  Check: not IsAdminInstallMode()

[UninstallDelete]
Type: files; Name: "{app}\{#ConfigurationPageName}.url"
Type: files; Name: "{app}\syncthing.exe.old"

[Code]
const
  ERROR_MORE_DATA          = 234;
  SC_MANAGER_CONNECT       = 1;
  SERVICE_QUERY_STATUS     = 4;
  SERVICE_RUNNING          = 4;
  MIGRATION_FLAG_FILE_NAME = 'CONFIGURATION_HAS_BEEN_MIGRATED.txt';

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

// Global variables
var
  ConfigPage: TInputQueryWizardPage;                       // Custom wizard page
  AutoUpgradeInterval, ListenAddress, ListenPort: string;  // Configuration page values
  ServiceAccountUserName: string;

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

function InitializeSetup(): Boolean;
begin
  result := true;
  // Custom command line parameters
  AutoUpgradeInterval := GetPreviousData('AutoUpgradeInterval',
    Trim(ExpandConstant('{param:autoupgradeinterval|{#DefaultAutoUpgradeInterval}}')));
  ListenAddress := GetPreviousData('ListenAddress',
    Trim(ExpandConstant('{param:listenaddress|{#DefaultListenAddress}}')));
  ListenPort := GetPreviousData('ListenPort',
    Trim(ExpandConstant('{param:listenport|{#DefaultListenPort}}')));
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName',
      Trim(ExpandConstant('{param:serviceaccountusername|{#DefaultServiceAccountUserName}}')));
  end;
end;

procedure InitializeWizard();
begin
  // Custom configuration page
  ConfigPage := CreateInputQueryPage(wpSelectProgramGroup,
    CustomMessage('ConfigPageCaption'),
    CustomMessage('ConfigPageDescription'),
    CustomMessage('ConfigPageSubCaption'));
  ConfigPage.Add(FmtMessage(CustomMessage('ConfigPageItem0'), ['{#DefaultAutoUpgradeInterval}']), false);
  ConfigPage.Add(FmtMessage(CustomMessage('ConfigPageItem1'), ['{#DefaultListenAddress}']), false);
  ConfigPage.Add(FmtMessage(CustomMessage('ConfigPageItem2'), ['{#DefaultListenPort}']), false);
  ConfigPage.Values[0] := AutoUpgradeInterval;
  ConfigPage.Values[1] := ListenAddress;
  ConfigPage.Values[2] := ListenPort;
  WizardForm.LicenseAcceptedRadio.Checked := true;
end;

function InitializeUninstall(): Boolean;
begin
  result := true;
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName', '{#DefaultServiceAccountUserName}');
  end;
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'AutoUpgradeInterval', AutoUpgradeInterval);
  SetPreviousData(PreviousDataKey, 'ListenAddress', ListenAddress);
  SetPreviousData(PreviousDataKey, 'ListenPort', ListenPort);
  if IsAdminInstallMode() then
  begin
    SetPreviousData(PreviousDataKey, 'ServiceAccountUserName', ServiceAccountUserName);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  UpgradeInterval, Port: Integer;
begin
  result := true;
  if CurPageID = ConfigPage.ID then
  begin
    //-------------------------------------------------------------------------
    // 0 - Validate auto upgrade interval (>= 0 and <= 65535)
    UpgradeInterval := StrToIntDef(Trim(ConfigPage.Values[0]), -1);
    result := (UpgradeInterval >= 0) and (UpgradeInterval <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPageItem0NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPageItem0NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage.Edits[0];
      ConfigPage.Values[0] := '{#DefaultAutoUpgradeInterval}';
      ConfigPage.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    AutoUpgradeInterval := Trim(ConfigPage.Values[0]);
    //-------------------------------------------------------------------------
    // 1 - Validate listen address (not empty)
    result := Trim(ConfigPage.Values[1]) <> '';
    if not result then
    begin
      Log(CustomMessage('ConfigPageItem1Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPageItem1Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage.Edits[1];
      ConfigPage.Values[1] := '{#DefaultListenAddress}';
      ConfigPage.Edits[1].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenAddress := Trim(ConfigPage.Values[1]);
    //-------------------------------------------------------------------------
    // 2 - Validate listen port (>= 1024 and <= 65535)
    Port := StrToIntDef(Trim(ConfigPage.Values[2]), -1);
    result := (Port >= 1024) and (Port <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPageItem2NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPageItem2NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage.Edits[2];
      ConfigPage.Values[2] := '{#DefaultListenPort}';
      ConfigPage.Edits[2].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenPort := Trim(ConfigPage.Values[2]);
    //-------------------------------------------------------------------------
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: string): string;
var
  Info: string;
begin
  Info := '';
  // Show installation mode
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoInstallInfo') + NewLine + Space;
  if IsAdminInstallMode() then
    Info := Info + CustomMessage('ReadyMemoInstallAdmin') + NewLine + Space
      + FmtMessage(CustomMessage('ReadyMemoInstallAdminServiceAccountUserName'), [ServiceAccountUserName])
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
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoConfigInfo') + NewLine + Space;
  if StrToInt(AutoUpgradeInterval) <> 0 then
    Info := Info + FmtMessage(CustomMessage('ReadyMemoConfigItem0Enabled'), [AutoUpgradeInterval])
  else
    Info := Info + CustomMessage('ReadyMemoConfigItem0Disabled');
  Info := Info + NewLine;
  Info := Info + Space + CustomMessage('ReadyMemoConfigItem1') + ' ' + ListenAddress + NewLine
    + Space + CustomMessage('ReadyMemoConfigItem2') + ' ' + ListenPort;
  if MemoTasksInfo <> '' then
  begin
    if Info <> '' then
      Info := Info + NewLine + NewLine;
    Info := Info + MemoTasksInfo;
  end;
  result := Info;
end;

// Requires string param
function GetListenAddress(Param: string): string;
begin
  if (Trim(ListenAddress) = '0.0.0.0') or (Trim(ListenAddress) = '::') then
    result := '127.0.0.1'
  else
    result := ListenAddress;
end;

// Requires string param
function GetListenPort(Param: string): string;
begin
  result := ListenPort;
end;

function GetStartAfterInstall(): Boolean;
begin
  result := not ParamStrExists('/nostart');
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
    Log('Exec failed: ' + SysErrorMessage(result) + ' (' + IntToStr(result) + ')');
end;

function FirewallRuleExists(): Boolean;
begin
  result := ExecEx(ExpandConstant('{sys}\cscript.exe'),
    ExpandConstant('"{app}\{#ScriptNameSyncthingFirewallRule}" /test'),
    true) = 0;
end;

function LogonTaskExists(): Boolean;
begin
  result := ExecEx(ExpandConstant('{sys}\cscript.exe'),
    ExpandConstant('"{app}\{#ScriptNameSyncthingLogonTask}" /test'),
    true) = 0;
end;

function InstallOrResetService(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\startps.exe');
  Params := ExpandConstant('-Dqnw -W Hidden "{app}\Install-SyncthingService.ps1" -- -Install'
    + ' -ServiceAccountUserName "' + ServiceAccountUserName + '"'
    + ' -ServiceAccountDescription "{cm:ServiceAccountDescription}"'
    + ' -ServiceName "{#ServiceName}"'
    + ' -ServiceDisplayName "{cm:ServiceDisplayName}"'
    + ' -ServiceDescription "{cm:ServiceDescription}"'
    + ' -ServiceStartupType ');
  if WizardIsTaskSelected('startatboot') then
    Params := Params + 'SERVICE_DELAYED_AUTO_START'
  else
    Params := Params + 'SERVICE_DEMAND_START';
  Params := Params + ' -ServiceShutdownTimeout {#ServiceShutdownTimeout}';
  result := ExecEx(FileName, Params, true);
end;

function SetAppDirectoryPermissions(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{sys}\icacls.exe');
  Params := ExpandConstant('"{app}" /reset /t');
  ExecEx(FileName, Params, true);
  Params := ExpandConstant('"{app}" /grant "' + ServiceAccountUserName + ':(OI)(CI)M"');
  result := ExecEx(FileName, Params, true);
end;

function SetupConfiguration(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{sys}\cscript.exe');
  Params := ExpandConstant('"{app}\{#ScriptNameSetSyncthingConfig}"');
  if IsAdminInstallMode() then
    Params := Params + ' /service'
  else
    Params := Params + ' /currentuser';
  Params := Params + ' /autoupgradeinterval:' + AutoUpgradeInterval + ' /guiaddress:"'
    + ListenAddress + ':' + ListenPort + '"';
  if WizardSilent() then
    Params := Params + ' /silent';
  result := ExecEx(FileName, Params, true);
end;

function StopService(): Integer;
begin
  result := 0;
  if ServiceExists() then
    result := ExecEx(ExpandConstant('{app}\nssm.exe'), 'stop "{#ServiceName}"', true);
end;

function StartService(): Integer;
begin
  result := 0;
  if ServiceExists() and (not ServiceRunning()) then
    result := ExecEx(ExpandConstant('{app}\nssm.exe'), 'start "{#ServiceName}"', true);
end;

function RemoveService(): Integer;
var
  FileName, Params: string;
begin
  result := 0;
  if ServiceExists() then
  begin
    FileName := ExpandConstant('{app}\startps.exe');
    Params := ExpandConstant('-Dqnw -W Hidden "{app}\Install-SyncthingService.ps1" -- -Remove'
      + ' -ServiceAccountUserName "' + ServiceAccountUserName + '"'
      + ' -ServiceName "{#ServiceName}"');
    result := ExecEx(FileName, Params, true);
  end;
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

function JoinPath(Path1, Path2: string): string;
begin
  // Remove trailing '\' from Path1
  while Path1[Length(Path1)] = '\' do
    Path1 := Copy(Path1, 1, Length(Path1) - 1);
  // Remove leading '\' from Path2
  while Path2[1] = '\' do
    Path2 := Copy(Path2, 2, Length(Path2) - 1);
  // Concatenate with '\' separator
  result := Path1 + '\' + Path2;
end;

function GetLocalServiceLocalAppDataPath(): string;
var
  SWbemLocator, WMIService, UserProfile: Variant;
begin
  try
    SWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
    WMIService := SWbemLocator.ConnectServer('.', 'root\CIMV2');
    UserProfile := WMIService.Get('Win32_UserProfile.SID="S-1-5-19"');
    result := JoinPath(UserProfile.LocalPath, 'AppData\Local');
  except
    result := '';
  end;
end;

function LocalServiceConfigMigrationNeeded(): Boolean;
var
  LocalServiceConfigPath, LocalServiceConfigFileName,
    AppConfigPath, AppConfigFileName, FlagFileName: string;
begin
  LocalServiceConfigPath := JoinPath(GetLocalServiceLocalAppDataPath(), 'Syncthing');
  LocalServiceConfigFileName := JoinPath(LocalServiceConfigPath, 'config.xml');
  AppConfigPath := JoinPath(ExpandConstant('{autoappdata}'), 'Syncthing');
  AppConfigFileName := JoinPath(AppConfigPath, 'config.xml');
  FlagFileName := JoinPath(LocalServiceConfigPath, MIGRATION_FLAG_FILE_NAME);
  result := FileExists(LocalServiceConfigFileName) and
    (not FileExists(AppConfigFileName)) and
    (not FileExists(FlagFileName));
  if result then
  begin
    Log(FmtMessage(CustomMessage('MigrationNeededMessage'), [LocalServiceConfigPath, AppConfigPath]));
  end;
end;

function MigrateLocalServiceConfig(): Boolean;
var
  Restart: Boolean;
  LocalServiceConfigPath, AppConfigPath, FileName, Params: string;
begin
  // Need to stop and restart service (if running) due to in-use files
  Restart := ServiceRunning();
  if Restart then
    StopService();
  LocalServiceConfigPath := JoinPath(GetLocalServiceLocalAppDataPath(), 'Syncthing');
  AppConfigPath := JoinPath(ExpandConstant('{autoappdata}'), 'Syncthing');
  FileName := ExpandConstant('{sys}\xcopy.exe');
  Params := FmtMessage('"%1\*" "%2" /C /E /F /H /I /K /R /Y', [LocalServiceConfigPath, AppConfigPath]);
  result := ExecEx(FileName, Params, true) = 0;
  if result then
  begin
    Log(FmtMessage(CustomMessage('MigrationSucceededMessage'), [LocalServiceConfigPath, AppConfigPath]));
    SaveStringToFile(JoinPath(LocalServiceConfigPath, MIGRATION_FLAG_FILE_NAME),
      FmtMessage(CustomMessage('MigratedConfigFlagFileText') + #13#10, [AppConfigPath]),
      false);
  end
  else
  begin
    Log(FmtMessage(CustomMessage('MigrationFailedMessage'), [LocalServiceConfigPath, AppConfigPath]));
  end;
  if Restart then
    StartService();
end;

procedure RemoveMigratedConfig();
var
  LocalServiceConfigPath, ConfigFileName, FlagFileName: string;
begin
  LocalServiceConfigPath := JoinPath(GetLocalServiceLocalAppDataPath(), 'Syncthing');
  ConfigFileName := JoinPath(LocalServiceConfigPath, 'config.xml');
  FlagFileName := JoinPath(LocalServiceConfigPath, MIGRATION_FLAG_FILE_NAME);
  if FileExists(ConfigFileName) and FileExists(FlagFileName) then
  begin
    if DelTree(LocalServiceConfigPath, true, true, true) then
      Log(FmtMessage(CustomMessage('MigratedConfigRemoveSuccess'), [LocalServiceConfigPath]))
    else
      Log(FmtMessage(CustomMessage('MigratedConfigRemoveFailure'), [LocalServiceConfigPath]));
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  LocalServiceConfigPath, AppConfigPath: string;
  RemoveOldConfig: Boolean;
begin
  if CurStep = ssPostInstall then
  begin
    if IsAdminInstallMode() then
    begin
      InstallOrResetService();
      SetAppDirectoryPermissions();
      if LocalServiceConfigMigrationNeeded() then
      begin
        if MigrateLocalServiceConfig() then
        begin
          LocalServiceConfigPath := JoinPath(GetLocalServiceLocalAppDataPath(), 'Syncthing');
          AppConfigPath := JoinPath(ExpandConstant('{autoappdata}'), 'Syncthing');
          RemoveOldConfig := SuppressibleTaskDialogMsgBox(CustomMessage('MigratedConfigRemoveOldInstruction'),
            FmtMessage(CustomMessage('MigratedConfigRemoveOldText'), [LocalServiceConfigPath, AppConfigPath]),
            mbConfirmation,
            MB_YESNO, [CustomMessage('MigratedConfigRemoveOldButton1'), CustomMessage('MigratedConfigRemoveOldButton2')],
            0,
            IDYES) = IDYES;
          if RemoveOldConfig then
            RemoveMigratedConfig();
        end;
      end;
    end;
    SetupConfiguration();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if IsAdminInstallMode() then
    begin
      if ServiceExists() then
        RemoveService();
    end
    else
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
