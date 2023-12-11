; Syncthing.iss - Syncthing Windows Setup
; Written by Bill Stewart (bstewart AT iname.com) for Syncthing

; Windows Inno Setup installer for Syncthing (https://syncthing.net/)
; * see LICENSE for license
; * See README.md for documentation
; * See building.md for build/localization info

#if Ver < EncodeVer(6,0,0,0)
#error This script requires Inno Setup 6 or later
#endif

#define UninstallIfVersionOlderThan "1.27.0"
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
#define DefaultRelaysEnabled "true"
#define DefaultServiceAccountUserName "SyncthingServiceAcct"
#define ConfigurationPageName "ConfigurationPage"
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
PrivilegesRequired=lowest
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
UninstallDisplayName={#AppName} {code:GetInstallationMode}
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
; Support automatic uninstall of older versions
Source: "UninsIS.dll"; Flags: dontcopy
; WSH scripts (use preprocessor to support multiple languages)
#define protected i 0
#sub LocalizeWSHScripts
#define protected Language Languages[i]
#define protected ScriptNameSetConfig    ReadIni(LocalizationFile, Language, "ScriptNameSetSyncthingConfig")
#define protected ScriptNameFirewallRule ReadIni(LocalizationFile, Language, "ScriptNameSyncthingFirewallRule")
#define protected ScriptNameLogonTask    ReadIni(LocalizationFile, Language, "ScriptNameSyncthingLogonTask")
#define protected ScriptNameStart        ReadIni(LocalizationFile, Language, "ScriptNameStartSyncthing")
#define protected ScriptNameStop         ReadIni(LocalizationFile, Language, "ScriptNameStopSyncthing")
Source: "{#ScriptNameFirewallRule}"; DestDir: "{app}"; DestName: "{#ScriptNameSyncthingFirewallRule}"; Languages: {#Language}
Source: "{#ScriptNameSetConfig}";    DestDir: "{app}"; DestName: "{#ScriptNameSetSyncthingConfig}";    Languages: {#Language}
Source: "{#ScriptNameLogonTask}";    DestDir: "{app}"; DestName: "{#ScriptNameSyncthingLogonTask}";    Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStart}";        DestDir: "{app}"; DestName: "{#ScriptNameStartSyncthing}";        Languages: {#language}; Check: not IsAdminInstallMode()
Source: "{#ScriptNameStop}";         DestDir: "{app}"; DestName: "{#ScriptNameStopSyncthing}";         Languages: {#language}; Check: not IsAdminInstallMode()
#endsub
#for { i = 0; i < NumLanguages; i++ } LocalizeWSHScripts
; General files
Source: "redist\*"; DestDir: "{app}"; Flags: createallsubdirs recursesubdirs
; PowerShell scripts
Source: "Install-SyncthingService.ps1";              DestDir: "{app}"; Check: IsAdminInstallMode()
Source: "Reset-SyncthingServiceAccountPassword.ps1"; DestDir: "{app}"; Check: IsAdminInstallMode()
; shawl license
Source: "shawl-license.txt"; DestDir: "{app}"; Check: IsAdminInstallMode()
; 386 binaries
Source: "bin\386\syncthing.exe";   DestDir: "{app}"; Check: not Is64BitInstallMode()
Source: "ServMan\386\ServMan.exe"; DestDir: "{app}"; Check: not Is64BitInstallMode()
Source: "shawl\386\shawl.exe";     DestDir: "{app}"; Check: ((not Is64BitInstallMode()) or (Is64BitInstallMode() and IsARM64())) and IsAdminInstallMode()
Source: "startps\386\startps.exe"; DestDir: "{app}"; Check: ((not Is64BitInstallMode()) or (Is64BitInstallMode() and IsARM64())) and IsAdminInstallMode()
; amd64 binaries
Source: "bin\amd64\syncthing.exe";   DestDir: "{app}"; Flags: solidbreak; Check: Is64BitInstallMode() and IsX64()
Source: "ServMan\amd64\ServMan.exe"; DestDir: "{app}";                    Check: Is64BitInstallMode() and IsX64() and IsAdminInstallMode()
Source: "shawl\amd64\shawl.exe";     DestDir: "{app}";                    Check: Is64BitInstallMode() and IsX64() and IsAdminInstallMode()
Source: "startps\amd64\startps.exe"; DestDir: "{app}";                    Check: Is64BitInstallMode() and IsX64() and IsAdminInstallMode()
; arm64 binaries
Source: "bin\arm64\syncthing.exe"; DestDir: "{app}"; Flags: solidbreak; Check: Is64BitInstallMode() and IsARM64()

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
Filename: "{app}\SetupVersion.ini"; \
  Section: "Setup"; \
  Key: "Version"; \
  String: "{#SetupVersion}"
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
Name: startserviceafterinstall; \
  Description: "{cm:TasksStartServiceAfterInstall}"; \
  Check: IsAdminInstallMode()
; Non-admin
Name: startatlogon; \
  Description: "{cm:TasksStartAtLogon}"; \
  Check: (not IsAdminInstallMode()) and (not LogonTaskExists())
Name: startafterinstall; \
  Description: "{cm:TasksStartAfterInstall}"; \
  Check: not IsAdminInstallMode()

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
; 'startafterinstall' task
Filename: "{sys}\cscript.exe"; \
  Parameters: """{app}\{#ScriptNameStartSyncthing}"" /silent"; \
  Flags: runhidden; \
  StatusMsg: "{cm:RunStatusMsg}"; \
  Check: (not IsAdminInstallMode()) and FirewallRuleExists(); \
  Tasks: startafterinstall
; postinstall
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Description: "{cm:RunPostInstallOpenConfigPage}"; \
  Flags: shellexec postinstall skipifsilent; \
  Check: ShowPostInstallCheckbox() and IsSyncthingRunning()

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
Type: files; Name: "{app}\SetupVersion.ini"
Type: files; Name: "{app}\{#ConfigurationPageName}.url"
Type: files; Name: "{app}\syncthing.exe.old"

[Code]
const
  ERROR_MORE_DATA               = 234;
  ERROR_SERVICE_ALREADY_RUNNING = 1056;
  ERROR_SERVICE_NOT_ACTIVE      = 1062;

// Global variables
var
  ConfigPage0: TInputQueryWizardPage;
  // Configuration page values
  AutoUpgradeInterval, ListenAddress, ListenPort, RelaysEnabled: string;
  ServiceAccountUserName: string;

// Windows API functions
function GetUserNameExW(NameFormat: Integer; lpNameBuffer: string; var nSize: DWORD): Boolean;
  external 'GetUserNameExW@secur32.dll stdcall';

// UninsIS.dll functions
function DLLCompareVersionStrings(Version1, Version2: string): Integer;
  external 'CompareVersionStrings@files:UninsIS.dll stdcall setuponly';
function DLLIsISPackageInstalled(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'IsISPackageInstalled@files:UninsIS.dll stdcall setuponly';
function DLLUninstallISPackage(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'UninstallISPackage@files:UninsIS.dll stdcall setuponly';

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

function BoolToStr(const B: Boolean): string;
begin
  if B then
    result := 'true'
  else
    result := 'false';
end;

// Checks if Syncthing process is running
function IsSyncthingRunning(): Boolean;
var
  MilliSecs, Count: Integer;
  AppDir, WQLQuery: string;
  SWbemLocator, WMIService, SWbemObjectSet: Variant;
begin
  MilliSecs := 1000;
  result := false;
  for Count := 0 to 9 do
  begin
    AppDir := AddBackslash(ExpandConstant('{app}'));
    StringChangeEx(AppDir, '\', '\\', true);
    WQLQuery := Format('SELECT Name FROM Win32_Process' +
      ' WHERE (ExecutablePath LIKE "%s%%") AND (Name = "syncthing.exe")', [AppDir]);
    Log(FmtMessage(CustomMessage('IsRunningWMIQuery'), [WQLQuery]));
    try
      SWbemLocator := CreateOleObject('WbemScripting.SWbemLocator');
      WMIService := SWbemLocator.ConnectServer('', 'root\CIMV2');
      SWbemObjectSet := WMIService.ExecQuery(WQLQuery);
      result := (not VarIsNull(SWbemObjectSet)) and (SWbemObjectSet.Count > 0);
      Log(FmtMessage(CustomMessage('IsRunningWMIQueryResult'), [BoolToStr(result)]));
    except
      Log(CustomMessage('IsRunningWMIExceptionMessage'));
      break;
    end; //try
    if result then
      break;
    Log(FmtMessage(CustomMessage('IsRunningWMIPauseMessage'), [IntToStr(MilliSecs)]));
    Sleep(MilliSecs);
  end;
end;

// UninsIS.dll - Returns true if package is detected as installed, or false otherwise
function IsISPackageInstalled(): Boolean;
begin
  result := DLLIsISPackageInstalled('{#AppID}',  // AppId
    DWORD(Is64BitInstallMode()),                 // Is64BitInstallMode
    DWORD(IsAdminInstallMode())) = 1;            // IsAdminInstallMode
end;

// UninsIS.dll - Returns:
// < 0 if Version1 < Version2
// 0   if Version1 = Version2
// > 0 if Version1 > Version2
function CompareVersionStrings(const Version1, Version2: string): Integer;
begin
  result := DLLCompareVersionStrings(Version1, Version2);
end;

// UninsIS.dll - Returns 0 for success, non-zero for failure
function UninstallISPackage(): DWORD;
begin
  result := DLLUninstallISPackage('{#AppID}',  // AppId
    DWORD(Is64BitInstallMode()),               // Is64BitInstallMode
    DWORD(IsAdminInstallMode()));              // IsAdminInstallMode
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

function ShowPostInstallCheckbox(): Boolean;
begin
  result := not ParamStrExists('/noconfigpage');
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
  RelaysEnabled := GetPreviousData('RelaysEnabled',
    Trim(ExpandConstant('{param:relaysenabled|{#DefaultRelaysEnabled}}')));
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName',
      Trim(ExpandConstant('{param:serviceaccountusername|{#DefaultServiceAccountUserName}}')));
  end;
end;

procedure InitializeWizard();
begin
  // Custom configuration page
  ConfigPage0 := CreateInputQueryPage(wpSelectProgramGroup,
    CustomMessage('ConfigPage0Caption'),
    CustomMessage('ConfigPage0Description'),
    CustomMessage('ConfigPage0SubCaption'));
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item0'), ['{#DefaultAutoUpgradeInterval}']), false);
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item1'), ['{#DefaultListenAddress}']), false);
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item2'), ['{#DefaultListenPort}']), false);
  ConfigPage0.Add(FmtMessage(CustomMessage('ConfigPage0Item3'), ['{#DefaultRelaysEnabled}']), false);
  ConfigPage0.Values[0] := AutoUpgradeInterval;
  ConfigPage0.Values[1] := ListenAddress;
  ConfigPage0.Values[2] := ListenPort;
  ConfigPage0.Values[3] := RelaysEnabled;
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
  SetPreviousData(PreviousDataKey, 'RelaysEnabled', RelaysEnabled);
  if IsAdminInstallMode() then
  begin
    SetPreviousData(PreviousDataKey, 'ServiceAccountUserName', ServiceAccountUserName);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  UpgradeInterval, Port: Integer;
  Relays: string;
begin
  result := true;
  if CurPageID = ConfigPage0.ID then
  begin
    //-------------------------------------------------------------------------
    // 0 - Validate auto upgrade interval (>= 0 and <= 65535)
    UpgradeInterval := StrToIntDef(Trim(ConfigPage0.Values[0]), -1);
    result := (UpgradeInterval >= 0) and (UpgradeInterval <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item0NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item0NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[0];
      ConfigPage0.Values[0] := '{#DefaultAutoUpgradeInterval}';
      ConfigPage0.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    AutoUpgradeInterval := Trim(ConfigPage0.Values[0]);
    //-------------------------------------------------------------------------
    // 1 - Validate listen address (not empty)
    result := Trim(ConfigPage0.Values[1]) <> '';
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item1Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item1Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[1];
      ConfigPage0.Values[1] := '{#DefaultListenAddress}';
      ConfigPage0.Edits[1].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenAddress := Trim(ConfigPage0.Values[1]);
    //-------------------------------------------------------------------------
    // 2 - Validate listen port (>= 1024 and <= 65535)
    Port := StrToIntDef(Trim(ConfigPage0.Values[2]), -1);
    result := (Port >= 1024) and (Port <= 65535);
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item2NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item2NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[2];
      ConfigPage0.Values[2] := '{#DefaultListenPort}';
      ConfigPage0.Edits[2].SelectAll();
      exit;
    end;
    // Update global based on page
    ListenPort := Trim(ConfigPage0.Values[2]);
    //-------------------------------------------------------------------------
    // 3 - Validate relays enabled ('true' or 'false')
    Relays := Lowercase(Trim(ConfigPage0.Values[3]));
    result := (Relays = 'false') or (Relays = 'true');
    if not result then
    begin
      Log(CustomMessage('ConfigPage0Item3NotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ConfigPage0Item3NotValid'), mbError, MB_OK);
      WizardForm.ActiveControl := ConfigPage0.Edits[3];
      ConfigPage0.Values[3] := '{#DefaultRelaysEnabled}';
      ConfigPage0.Edits[3].SelectAll();
      exit;
    end;
    // Update global based on page
    RelaysEnabled := Relays;
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
  Info := Info + NewLine;
  if RelaysEnabled = 'false' then
    Info := Info + Space + CustomMessage('ReadyMemoConfigItem3Disabled')
  else
    Info := Info + Space + CustomMessage('ReadyMemoConfigItem3Enabled');
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

// Requires string param
function GetInstallationMode(Param: string): string;
begin
  if IsAdminInstallMode() then
    result := '(admin)'
  else
    result := '(current user)';
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

function ServiceExists(): Boolean;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--exists "{#ServiceName}"';
  result := ExecEx(FileName, Params, true) = 0;
end;

function ServiceRunning(): Boolean;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--state "{#ServiceName}"';
  // ServMan --state exit code 904 = running
  result := ExecEx(FileName, Params, true) = 904;
end;

function StopService(): Boolean;
var
  FileName, Params: string;
  Status: Integer;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := ' --stop "{#ServiceName}"';
  Status := ExecEx(FileName, Params, true);
  result := (Status = 0) or (Status = ERROR_SERVICE_NOT_ACTIVE);
end;

function StartService(): Boolean;
var
  FileName, Params: string;
  Status: Integer;
begin
  FileName := ExpandConstant('{app}\ServMan.exe');
  Params := '--start "{#ServiceName}"';
  Status := ExecEx(FileName, Params, true);
  result := (Status = 0) or (Status = ERROR_SERVICE_ALREADY_RUNNING);
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
    Params := Params + 'delayed-auto'
  else
    Params := Params + 'demand';
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
  Params := Params + ' /autoupgradeinterval:' + AutoUpgradeInterval
    + ' /guiaddress:"' + ListenAddress + ':' + ListenPort + '"'
    + ' /relaysenabled:' + RelaysEnabled;
  if WizardSilent() then
    Params := Params + ' /silent';
  result := ExecEx(FileName, Params, true);
end;

function RemoveService(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\startps.exe');
  Params := ExpandConstant('-Dqnw -W Hidden "{app}\Install-SyncthingService.ps1" -- -Remove'
    + ' -ServiceAccountUserName "' + ServiceAccountUserName + '"'
    + ' -ServiceName "{#ServiceName}"');
  result := ExecEx(FileName, Params, true);
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

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  InstalledSetupVersion: string;
begin
  result := '';
  if IsISPackageInstalled() then
  begin
    InstalledSetupVersion := GetIniString('Setup', 'Version', '', ExpandConstant('{app}\SetupVersion.ini'));
    if (InstalledSetupVersion = '') or
      (CompareVersionStrings(InstalledSetupVersion, '{#UninstallIfVersionOlderThan}') < 0) then
    begin
      // Uninstall if:
      // Package is installed AND
      //   Can't get setup version from SetupVersion.ini, OR
      //   Version in SetupVersion.ini is older than {#UninstallIfVersionOlderThan}
      if UninstallISPackage() <> 0 then
      begin
        result := CustomMessage('PrepareToInstallErrorMessage0');
        exit;
      end
    end
    else if CompareVersionStrings(InstalledSetupVersion, '{#SetupVersion}') > 0 then
    begin
      // Installed version > installing version = downgrade
      result := FmtMessage(CustomMessage('PrepareToInstallErrorMessage1'), [InstalledSetupVersion, '{#SetupVersion}']);
      exit;
    end;
    if IsAdminInstallMode() then
    begin
      if ServiceExists() and ServiceRunning() then
        StopService();
    end
    else
    begin
      ExecEx(ExpandConstant('{sys}\cscript.exe'),
        ExpandConstant('"{app}\{#ScriptNameStopSyncthing}" /silent'),
        true);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    if IsAdminInstallMode() then
    begin
      InstallOrResetService();
      SetAppDirectoryPermissions();
    end;
    SetupConfiguration();
    if WizardIsTaskSelected('startserviceafterinstall') then
    begin
      if ServiceExists() and (not ServiceRunning()) then
        StartService();
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
