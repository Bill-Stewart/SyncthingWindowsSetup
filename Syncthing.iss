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
#define SetupVersion AppVersion + ".2"
#define ServiceName "syncthing"
#define ServiceStopTimeout "10000"
#define DefaultAutoUpgradeInterval "12"
#define DefaultListenAddress "127.0.0.1"
#define DefaultListenPort "8384"
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
WizardStyle=modern
WizardSizePercent=120
UninstallFilesDir={app}\uninstall
UninstallDisplayIcon={app}\syncthing.exe,0
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoProductVersion={#AppVersion}
VersionInfoVersion={#SetupVersion}

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
#sub LocalizeScripts
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
#for { i = 0; i < NumLanguages; i++ } LocalizeScripts
; General files
Source: "redist\*"; DestDir: "{app}"; Flags: ignoreversion createallsubdirs recursesubdirs
; 64-bit binaries
Source: "bin\amd64\syncthing.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode()
Source: "nssm\amd64\nssm.exe";     DestDir: "{app}"; Flags: ignoreversion; Check: Is64BitInstallMode() and IsAdminInstallMode()
; 32-bit binaries
Source: "bin\386\syncthing.exe"; DestDir: "{app}"; Flags: ignoreversion solidbreak; Check: not Is64BitInstallMode()
Source: "nssm\386\nssm.exe";     DestDir: "{app}"; Flags: ignoreversion; Check: (not Is64BitInstallMode()) and IsAdminInstallMode()

; Why use cscript.exe vs. wscript.exe?
; * Use cscript.exe for hidden scripts (so error doesn't block execution)
; * Use wscript.exe for interactive scripts

[Icons]
; Both admin and non-admin
Name: "{group}\{cm:ShortcutNameFAQ}";               Filename: "{app}\extra\FAQ.pdf"
Name: "{group}\{cm:ShortcutNameGettingStarted}";    Filename: "{app}\extra\Getting-Started.pdf"
Name: "{group}\{cm:ShortcutNameConfigurationPage}"; Filename: "{app}\{#ConfigurationPageName}.url"; Comment: "{cm:ShortcutNameConfigurationPageComment}"; IconFilename: "{app}\syncthing.exe"
; Admin: Configure service
Name: "{group}\{cm:ShortcutNameConfigureService}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameConfigSyncthingService}"""; Comment: "{cm:ShortcutNameConfigureServiceComment}"; IconFilename: "{app}\nssm.exe"; Flags: excludefromshowinnewinstall; Check: IsAdminInstallMode()
; Non-admin: Start and stop shortcuts
Name: "{group}\{cm:ShortcutNameStartSyncthing}"; Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameStartSyncthing}"""; Comment: "{cm:ShortcutNameStartSyncthingComment}"; IconFilename: "{app}\syncthing.exe"; Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameStopSyncthing}";  Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameStopSyncthing}""";  Comment: "{cm:ShortcutNameStopSyncthingComment}";  IconFilename: "{app}\syncthing.exe"; Check: not IsAdminInstallMode()

[INI]
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "URL";       String: "https://{code:GetListenAddress}:{code:GetListenPort}"
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "IconFile";  String: "{app}\syncthing.exe"
Filename: "{app}\{#ConfigurationPageName}.url"; Section: "InternetShortcut"; Key: "IconIndex"; String: "0"

[Tasks]
Name: startatboot;  Description: "{cm:TasksStartAtBoot}";  Check: IsAdminInstallMode() and (not ServiceExists())
Name: startatlogon; Description: "{cm:TasksStartAtLogon}"; Check: (not IsAdminInstallMode()) and (not LogonTaskExists())

[Run]
; Admin: Set directory permissions; add firewall rule
Filename: "{sys}\icacls.exe";  Parameters: """{app}"" /grant ""*S-1-5-19:(OI)(CI)M"" /t";                            Flags: runhidden; StatusMsg: "{cm:RunStatusMsg}"; Check: IsAdminInstallMode()
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create /elevated /silent"; Flags: runhidden; StatusMsg: "{cm:RunStatusMsg}"; Check: IsAdminInstallMode()
; Non-admin: Add Firewall rule; add logon task
Filename: "{sys}\wscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /create"; StatusMsg: "{cm:RunStatusMsg}"; Check: (not IsAdminInstallMode()) and (not FirewallRuleExists()) and (not WizardSilent())
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingLogonTask}"" /create /silent"; Flags: runhidden; StatusMsg: "{cm:RunStatusMsg}"; Tasks: startatlogon
; Both admin and non-admin: Set config.xml defaults
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSetSyncthingConfig}"" {code:GetSetConfigParams}"; Flags: runhidden; StatusMsg: "{cm:RunStatusMsg}"
; Admin postinstall
Filename: "{app}\nssm.exe"; Parameters: "start ""{#ServiceName}"""; Description: "{cm:RunPostInstallStartServiceDescription}"; Flags: runascurrentuser runhidden nowait postinstall; Check: IsAdmininstallMode() and GetStartAfterInstall() and ServiceExists() and (not ServiceRunning())
; Non-Admin postinstall
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameStartSyncthing}"" /silent"; Description: "{cm:RunPostInstallStartDescription}"; Flags: runhidden nowait postinstall; Check: (not IsAdminInstallMode()) and GetStartAfterInstall() and FirewallRuleExists()

[UninstallRun]
; Admin: remove firewall rule
Filename: "{sys}\cscript.exe"; Parameters: """{app}\{#ScriptNameSyncthingFirewallRule}"" /remove /elevated /silent"; Flags: runhidden; RunOnceId: removefwrule; Check: IsAdminInstallMode()
; Non-admin: remove logon task
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
  ConfigPage: TInputQueryWizardPage;                       // Custom wizard page
  AutoUpgradeInterval, ListenAddress, ListenPort: string;  // Configuration page values
  StartAfterInstall: Boolean;

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
  StartAfterInstall := not ParamStrExists('/nostart');
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
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'AutoUpgradeInterval', AutoUpgradeInterval);
  SetPreviousData(PreviousDataKey, 'ListenAddress', ListenAddress);
  SetPreviousData(PreviousDataKey, 'ListenPort', ListenPort);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  UpgradeInterval, Port: Integer;
begin
  result := true;
  if CurPageID = ConfigPage.ID then
  begin
    // Validate upgrade interval (>= 0 and <= 65535)
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
    AutoUpgradeInterval := ConfigPage.Values[0];
    // Validate listen address (not empty)
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
    ListenAddress := ConfigPage.Values[1];
    // Validate listen port (>= 1024 and <= 65535)
    Port := StrToIntDef(Trim(ConfigPage.Values[2]), -1);
    result := (Port >= 1024) and (Port <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPageItem2NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPageItem2NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage.Edits[1];
      ConfigPage.Values[2] := '{#DefaultListenPort}';
      ConfigPage.Edits[2].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenPort := ConfigPage.Values[2];
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
  Info := Info + CustomMessage('ReadyMemoInstallInfo') + NewLine + Space;
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
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoConfigInfo') + NewLine + Space;
  if StrToInt(AutoUpgradeInterval) <> 0 then
    Info := Info + FmtMessage(CustomMessage('ReadyMemoConfigItem0Enabled'), [AutoUpgradeInterval])
  else
    Info := Info + CustomMessage('ReadyMemoConfigItem0Disabled');
  Info := Info + NewLine;
  Info := Info + Space + CustomMessage('ReadyMemoConfigItem1') + ' ' + ListenAddress + NewLine +
    Space + CustomMessage('ReadyMemoConfigItem2') + ' ' + ListenPort;
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
  result := ListenAddress;
end;

// Requires string param
function GetListenPort(Param: string): string;
begin
  result := ListenPort;
end;

// Requires string param
function GetSetConfigParams(Param: string): string;
begin
  if IsAdminInstallMode() then
    result := '/localservice'
  else
    result := '/currentuser';
  result := result + ' /autoupgradeinterval:' + AutoUpgradeInterval;
  result := result + ' /guiaddress:"' + ListenAddress + ':' + ListenPort + '"';
end;

function GetStartAfterInstall(): Boolean;
begin
  result := StartAfterInstall;
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
    Params := 'set "{#ServiceName}" AppParameters "--no-browser --no-restart"';
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
    if WizardIsTaskSelected('startatboot') then
      Params := 'set "{#ServiceName}" Start SERVICE_DELAYED_AUTO_START'
    else
      Params := 'set "{#ServiceName}" Start SERVICE_DEMAND_START';
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
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if IsAdminInstallMode() then
    begin
      if ServiceExists() then
      begin
        if ServiceRunning() then
          StopService();
        RemoveService();
      end;
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
