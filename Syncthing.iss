; Syncthing.iss - Syncthing Windows Setup
; Written by Bill Stewart (bstewart AT iname.com) for Syncthing

; Windows Inno Setup installer for Syncthing (https://syncthing.net/)
; * see LICENSE for license
; * See README.md for documentation
; * See building.md for build/localization info

#if Ver < EncodeVer(6,3,3,0)
#error This script requires Inno Setup 6.3.3 or later
#endif

#define UninstallIfSetupVersionOlderThan "1.27.11"
#define AppID "{1EEA2B6F-FD76-47D7-B74C-03E14CF043F9}"
#define GitHubUserName "syncthing"
#define GitHubProjectName "syncthing"
#define GitHubVersionTagURLPattern "https://api.github.com/repos/%s/%s/releases/latest"
#define GitHubDownloadURLPattern "https://github.com/%s/%s/releases/download/%s/%s"
#define ZipFileNamePattern "syncthing-windows-%s-%s.zip"
#define UnzipPattern "*/syncthing.exe */AUTHORS.txt */README.txt */LICENSE.txt"
#define AppName "Syncthing"
#define AppPublisher "Syncthing Foundation"
#define AppURL "https://syncthing.net/"
#define IniFileName "SetupVersion.ini"
#define SetupVersion ReadIni(AddBackslash(SourcePath) + IniFileName, "Setup", "Version")
#define ServiceName "syncthing"
#define ServiceShutdownTimeout "10000"
#define DefaultAutoUpgradeInterval "12"
#define DefaultListenAddress "127.0.0.1"
#define DefaultListenPort "8384"
#define DefaultRelaysEnabled "true"
#define DefaultServiceAccountUserName "SyncthingServiceAcct"
#define ConfigurationPageName "ConfigurationPage"
#define LicenseFileName "License.rtf"
#define ScriptNameSetSyncthingConfig "SetSyncthingConfig.js"
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
MinVersion=10
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=no
CloseApplicationsFilter=*.exe
RestartApplications=yes
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableWelcomePage=yes
AllowNoIcons=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir=.
OutputBaseFilename=syncthing-windows-setup
Compression=lzma2/max
SolidCompression=yes
UsePreviousTasks=yes
WizardStyle=modern
WizardSizePercent=120
UninstallFilesDir={app}\uninstall
UninstallDisplayIcon={app}\syncthing.ico
UninstallDisplayName={code:GetUninstallDisplayName}
VersionInfoProductName={#AppName}
VersionInfoCompany={#AppPublisher}
VersionInfoVersion={#SetupVersion}

[Messages]
SetupWindowTitle=Syncthing Windows Setup

[Languages]
Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"; InfoBeforeFile: "en-README.rtf"

; See building.md file for localization details
#define protected
#define LocalizationFile AddBackslash(SourcePath) + "Localization.ini"
#define NumLanguages 1
#dim    Languages[NumLanguages]
#define Languages[0] "en"

[Files]
; Preprocessor localization
#define i 0
#sub LocalizeFiles
#define Language Languages[i]
#define FileNameLicense        ReadIni(LocalizationFile, Language, "LicenseFile")
#define ScriptNameSetConfig    ReadIni(LocalizationFile, Language, "ScriptNameSetSyncthingConfig")
#define ScriptNameFirewallRule ReadIni(LocalizationFile, Language, "ScriptNameSyncthingFirewallRule")
#define ScriptNameLogonTask    ReadIni(LocalizationFile, Language, "ScriptNameSyncthingLogonTask")
Source: "{#FileNameLicense}"; DestName: "{#LicenseFileName}"; flags: dontcopy
Source: "{#ScriptNameFirewallRule}"; DestDir: "{app}"; DestName: "{#ScriptNameSyncthingFirewallRule}"; Languages: "{#Language}"
Source: "{#ScriptNameSetConfig}"; DestDir: "{app}"; DestName: "{#ScriptNameSetSyncthingConfig}"; Languages: "{#Language}"
Source: "{#ScriptNameLogonTask}"; DestDir: "{app}"; DestName: "{#ScriptNameSyncthingLogonTask}"; Languages: "{#language}"; Check: not IsAdminInstallMode()
#endsub
#for { i = 0; i < NumLanguages; i++ } LocalizeFiles

; Installer-only
; Support automatic uninstall of older versions
Source: "UninsIS.dll"; Flags: dontcopy
; Process checking
Source: "ProcessCheck.dll"; Flags: dontcopy
; Command-line JSON parser (get latest version tag from GitHub)
Source: "jq.exe"; Flags: dontcopy
; unzip utility for extracting Syncthing after downloading
Source: "unzip.exe"; Flags: dontcopy

; Setup version INI file
Source: "{#IniFileName}"; DestDir: "{app}"

; shawl license
Source: "shawl-license.txt"; DestDir: "{app}"; Check: IsAdminInstallMode()

; Icon
Source: "syncthing.ico"; DestDir: "{app}"
; x86compatible binaries
Source: "binaries\i386\asmt.exe";    DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\ServMan.exe"; DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\shawl.exe";   DestDir: "{app}"; Check: (not IsX64Compatible()) and IsAdminInstallMode()
Source: "binaries\i386\stctl.exe";   DestDir: "{app}"; Check: (not IsX64Compatible()) and (not IsAdminInstallMode())
; x64compatible binaries
Source: "binaries\x86_64\asmt.exe";    DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode(); Flags: solidbreak
Source: "binaries\x86_64\ServMan.exe"; DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode()
Source: "binaries\x86_64\shawl.exe";   DestDir: "{app}"; Check: IsX64Compatible() and IsAdminInstallMode()
Source: "binaries\x86_64\stctl.exe";   DestDir: "{app}"; Check: IsX64Compatible() and (not IsAdminInstallMode())

[Dirs]
Name: "{autoappdata}\{#AppName}"; Attribs: notcontentindexed; Check: IsAdminInstallMode()

; When to use cscript.exe vs. wscript.exe:
; * Use cscript.exe for hidden scripts (so error doesn't block execution)
; * Use wscript.exe for interactive scripts

[Icons]
; Non-admin and admin icons
Name: "{group}\{cm:ShortcutNameConfigurationPage}"; \
  Filename: "{app}\{#ConfigurationPageName}.url"; \
  Comment: "{cm:ShortcutNameConfigurationPageComment}"; \
  IconFilename: "{app}\syncthing.ico"
Name: "{autodesktop}\{cm:ShortcutNameConfigurationPage}"; \
  Filename: "{app}\{#ConfigurationPageName}.url"; \
  Comment: "{cm:ShortcutNameConfigurationPageComment}"; \
  IconFilename: "{app}\syncthing.ico"; \
  Tasks: desktopicon
; Non-admin icons
Name: "{group}\{cm:ShortcutNameStartSyncthing}"; \
  Filename: "{app}\stctl.exe"; \
  Parameters: "--start"; \
  Comment: "{cm:ShortcutNameStartSyncthingComment}"; \
  Check: not IsAdminInstallMode()
Name: "{group}\{cm:ShortcutNameStopSyncthing}"; \
  Filename: "{app}\stctl.exe"; \
  Parameters: "--stop"; \
  Comment: "{cm:ShortcutNameStopSyncthingComment}"; \
  Check: not IsAdminInstallMode()

[INI]
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "URL"; \
  String: "https://{code:GetListenAddress}:{code:GetListenPort}"
Filename: "{app}\{#ConfigurationPageName}.url"; \
  Section: "InternetShortcut"; \
  Key: "IconFile"; \
  String: "{app}\syncthing.ico"
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
  Check: not IsAdminInstallMode(); \
  Flags: checkablealone
Name: startatlogon\acpoweronly; \
  Description: "{cm:TasksStartAtLogon_ACPowerOnly}"; \
  Check: not IsAdminInstallMode(); \
  Flags: dontinheritcheck unchecked
Name: startafterinstall; \
  Description: "{cm:TasksStartAfterInstall}"; \
  Check: not IsAdminInstallMode()
Name: desktopicon; \
  Description: "{cm:TasksCreateDesktopIcon}"; \
  Flags: unchecked

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
Type: files; Name: "{app}\{#ConfigurationPageName}.url"
Type: files; Name: "{app}\syncthing.exe.old"
Type: files; Name: "{app}\syncthing.exe"
Type: files; Name: "{app}\AUTHORS.txt"
Type: files; Name: "{app}\README.txt"
Type: files; Name: "{app}\LICENSE.txt"

[Code]

// General notes about online vs. offline installation:
// * LatestVersionTag gets set if we connected to github.com, downloaded latest
//   version JSON file, and retrieved the latest version tag using jq.exe
// * LatestVersionTag = '' if we couldn't get to github.com
// * Therefore, LatestVersionTag = '' means offline install
// * If offline (LatestVersionTag empty), ZipFilePath gets set by:
//   a. /zipfilepath= command line parameter, or
//   b. Wizard file selection page
// * If user specifies /zipfilepath, don't attempt to get latest version JSON
// * If online (LatestVersionTag not empty), ZipFilePath gets set in
//   NextButtonClick event
// * Install only proceeds if zip file tests ok (i.e., unzip -t returns 0)

const
  ERROR_MORE_DATA               = 234;
  ERROR_SERVICE_ALREADY_RUNNING = 1056;
  ERROR_SERVICE_NOT_ACTIVE      = 1062;

// Global variables
var
  OutputMsgMemoPage0: TOutputMsgMemoWizardPage;
  ConfigPage0: TInputQueryWizardPage;
  FilePage0: TInputFileWizardPage;
  DownloadPage0: TDownloadWizardPage;
  // Configuration page values
  AutoUpgradeInterval, ListenAddress, ListenPort, RelaysEnabled: string;
  ServiceAccountUserName, ExecOutputFirstLine, ZipFilePath, LatestVersionTag: string;

// Windows API functions
function GetUserNameExW(NameFormat: Integer; lpNameBuffer: string; var nSize: DWORD): Boolean;
  external 'GetUserNameExW@secur32.dll stdcall setuponly';

// UninsIS.dll functions
function DLLCompareVersionStrings(Version1, Version2: string): Integer;
  external 'CompareVersionStrings@files:UninsIS.dll stdcall setuponly';
function DLLIsISPackageInstalled(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'IsISPackageInstalled@files:UninsIS.dll stdcall setuponly';
function DLLUninstallISPackage(AppId: string; Is64BitInstallMode, IsAdminInstallMode: DWORD): DWORD;
  external 'UninstallISPackage@files:UninsIS.dll stdcall setuponly';

// ProcessCheck.dll functions
function DLLFindProcess(PathName: string; var Found: DWORD): DWORD;
  external 'FindProcess@files:ProcessCheck.dll stdcall setuponly';

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

function IsSyncthingRunning(): Boolean;
var
  PathName: string;
  Found: DWORD;
begin
  Sleep(500);
  result := false;
  PathName := ExpandConstant('{app}\syncthing.exe');
  if DLLFindProcess(PathName, Found) = 0 then
  begin
    result := Found = 1;
    if result then
      Log(FmtMessage(CustomMessage('ProcessCheckSucceededRunning'), [PathName]))
    else
      Log(FmtMessage(CustomMessage('ProcessCheckSucceededNotRunning'), [PathName]));
  end
  else
    Log(CustomMessage('ProcessCheckFailed'));
end;

// UninsIS.dll - Returns true if package is detected as installed,
// or false otherwise
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

function IsDomainController(): Boolean;
var
  VersionInfo: TWindowsVersion;
begin
  GetWindowsVersionEx(VersionInfo);
  result := VersionInfo.ProductType = VER_NT_DOMAIN_CONTROLLER;
end;

function IsWshJsScriptRegistrationValid(): Boolean;
var
  Value: string;
begin
  result := RegQueryStringValue(HKEY_CLASSES_ROOT, '.js', '', Value);
  if result then
    result := SameText(Value, 'JSFile');
end;

procedure OnExecAndLogOutput(const S: String; const Error, FirstLine: Boolean);
begin
  if (not Error) and (ExecOutputFirstLine = '') and (Trim(S) <> '') then
    ExecOutputFirstLine := S;  // Store first line of non-empty output
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
  OK := ExecAndLogOutput(FileName,  // Filename
    Params,                         // Params
    '',                             // WorkingDir
    ShowCmd,                        // ShowCmd
    ewWaitUntilTerminated,          // TExecWait
    result,                         // ResultCode
    @OnExecAndLogOutput);           // TOnLog
  Log(Format('ExecEx: "%s" %s', [FileName, Params]));
  if OK then
    Log(Format('ExecEx exit code: %s', [IntToStr(result)]))
  else
    Log(Format('ExecEx failed: %s (%s)', [SysErrorMessage(result), IntToStr(result)]));
end;

function TestZipFile(const ZipFilePath: string): Boolean;
begin
  result := ExecEx(ExpandConstant('{tmp}\unzip.exe'),
    ExpandConstant(Format('-t "%s" {#UnzipPattern}', [ZipFilePath])), true) = 0;
end;

function OnDownloadProgress(const Url, Filename: string; const Progress, ProgressMax: Int64): Boolean;
begin
  result := true;
  if Progress = ProgressMax then
    Log(CustomMessage('DownloadFileSucceeded'));
end;

function DownloadFile(const URL, LocalFileName: string): Boolean;
var
  BytesDownloaded: Int64;
begin
  result := false;
  try
    BytesDownloaded := DownloadTemporaryFile(URL, LocalFileName, '', @OnDownloadProgress);
    result := BytesDownloaded > 0;
  except
  end;
end;

function GetLatestVersionJsonFilePath(): string;
var
  URL, UniqueFilePath: string;
begin
  result := '';
  URL := Format('{#GitHubVersionTagURLPattern}', ['{#GitHubUserName}', '{#GitHubProjectName}']);
  UniqueFilePath := GenerateUniqueName(ExpandConstant('{tmp}'), '.json');
  if DownloadFile(URL, ExtractFileName(UniqueFilePath)) then
    result := UniqueFilePath;
end;

procedure GetLatestVersionTag();
var
  JsonFilePath: string;
begin
  if LatestVersionTag <> '' then
    exit;
  JsonFilePath := GetLatestVersionJsonFilePath();
  if JsonFilePath = '' then
    exit;
  if ExecEx(ExpandConstant('{tmp}\jq.exe'), '-r .name "' + JsonFilePath + '"', true) = 0 then
  begin
    LatestVersionTag := ExecOutputFirstLine;
    Log('Latest version tag: ' + LatestVersionTag);
  end
  else
    Log('Failed to get latest version tag');
end;

function InitializeSetup(): Boolean;
var
  Msg: string;
begin
  if IsAdminInstallMode() then
  begin
    ServiceAccountUserName := GetPreviousData('ServiceAccountUserName',
      Trim(ExpandConstant('{param:serviceaccountusername|{#DefaultServiceAccountUserName}}')));
    result := not IsDomainController();
    if not result then
    begin
      Msg := CustomMessage('InitializeSetupError0');
      Log(Msg);
      if not WizardSilent() then
        MsgBox(Msg, mbCriticalError, MB_OK);
      exit;
    end;
  end;
  result := IsWshJsScriptRegistrationValid();
  if not result then
  begin
    Msg := CustomMessage('InitializeSetupError1');
    Log(Msg);
    if not WizardSilent() then
      MsgBox(Msg, mbCriticalError, MB_OK);
    exit;
  end;
  ExecOutputFirstLine := '';
  // Custom command line parameters
  AutoUpgradeInterval := GetPreviousData('AutoUpgradeInterval',
    Trim(ExpandConstant('{param:autoupgradeinterval|{#DefaultAutoUpgradeInterval}}')));
  ListenAddress := GetPreviousData('ListenAddress',
    Trim(ExpandConstant('{param:listenaddress|{#DefaultListenAddress}}')));
  ListenPort := GetPreviousData('ListenPort',
    Trim(ExpandConstant('{param:listenport|{#DefaultListenPort}}')));
  RelaysEnabled := GetPreviousData('RelaysEnabled',
    Trim(ExpandConstant('{param:relaysenabled|{#DefaultRelaysEnabled}}')));
  ExtractTemporaryFile('unzip.exe');
  ZipFilePath := Trim(ExpandConstant('{param:zipfilepath}'));
  if ZipFilePath = '' then
  begin
    // Zip file path not specified on command line; try to get it dynamically
    ExtractTemporaryFile('jq.exe');
    GetLatestVersionTag();
    if LatestVersionTag = '' then
    begin
      Msg := CustomMessage('InitializeSetupWarning0');
      Log(Msg);
    end;
  end
  else
  begin
    // Assume installer directory if no path specifed with zip file name
    if Pos('\', ZipFilePath) = 0 then
      ZipFilePath := ExpandConstant('{src}\') + ZipFilePath;
  end;
end;

procedure InitializeWizard();
var
  LicenseFileText: AnsiString;
begin
  // Custom memo page(s)
  ExtractTemporaryFile('{#LicenseFileName}');
  if LoadStringFromFile(ExpandConstant('{tmp}\{#LicenseFileName}'), LicenseFileText) then
  begin
    OutputMsgMemoPage0 := CreateOutputMsgMemoPage(wpInfoBefore,
      CustomMessage('MemoPage0Caption'),
      CustomMessage('MemoPage0Description'),
      CustomMessage('MemoPage0SubCaption'),
      LicenseFileText);
  end;
  // Custom file page(s)
  FilePage0 := CreateInputFilePage(OutputMsgMemoPage0.ID,
    CustomMessage('FilePage0Caption'),
    CustomMessage('FilePage0Description'),
    CustomMessage('FilePage0SubCaption'));
  FilePage0.Add(CustomMessage('FilePage0Prompt'), CustomMessage('FilePage0Filter'), '.zip');
  if ZipFilePath <> '' then
    FilePage0.Values[0] := ZipFilePath;
  // Custom configuration page(s)
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
  // Custom download page(s)
  DownloadPage0 := CreateDownloadPage(SetupMessage(msgWizardPreparing),
    SetupMessage(msgPreparingDesc), @OnDownloadProgress);
  DownloadPage0.ShowBaseNameInsteadOfUrl := true;
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

function GetDownloadFileName(): string;
var
  ProcArch: string;
begin
  result := '';
  case ProcessorArchitecture() of
    paX86, paUnknown: ProcArch := '386';
    paX64: ProcArch := 'amd64';
    paArm64: ProcArch := 'arm64';
  else
    exit;
  end;
  result := Format('{#ZipfileNamePattern}', [ProcArch, LatestVersionTag]);
end;

function GetDownloadURL(const DownloadFileName: string): string;
begin
  result := '';
  if LatestVersionTag = '' then
    exit;
  result := Format('{#GitHubDownloadURLPattern}', ['{#GitHubUserName}',
    '{#GitHubProjectName}', LatestVersionTag, DownloadFileName]);
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  result := false;
  if PageID = FilePage0.ID then
  begin
    // Skip zip file page if we were able to get latest version tag
    result := LatestVersionTag <> '';
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  UpgradeInterval, Port: Integer;
  Relays, DownloadFileName, DownloadURL, Msg: string;
begin
  result := true;
  if CurPageID = FilePage0.ID then
  begin
    result := Trim(FilePage0.Values[0]) <> '';
    if not result then
    begin
      Log(CustomMessage('FilePage0Item0Empty'));
      if not WizardSilent() then
        MsgBox(CustomMessage('FilePage0Item0Empty'), mbError, MB_OK);
      WizardForm.ActiveControl := FilePage0.Edits[0];
      FilePage0.Values[0] := '';
      exit;
    end;
    result := FileExists(FilePage0.Values[0]);
    if not result then
    begin
      Log(CustomMessage('ZipFilePathNotFound'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ZipFilePathNotFound'), mbError, MB_OK);
      WizardForm.ActiveControl := FilePage0.Edits[0];
      FilePage0.Edits[0].SelectAll();
      exit;
    end;
    result := TestZipFile(FilePage0.Values[0]);
    if not result then
    begin
      Log(CustomMessage('ZipFileNotValid'));
      if not WizardSilent() then
        MsgBox(CustomMessage('ZipFileNotValid'), mbError, MB_OK);
      FilePage0.Edits[0].SelectAll();
      exit;
    end;
    // Update global based on page
    ZipFilePath := Trim(FilePage0.Values[0]);
  end
  else if CurPageID = ConfigPage0.ID then
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
  end
  else if CurPageID = wpReady then
  begin
    // No need to download if we already have zip file path
    if ZipFilePath <> '' then
      exit;
    DownloadFileName := GetDownloadFileName();
    DownloadURL := GetDownloadURL(DownloadFileName);
    DownloadPage0.Clear();
    DownloadPage0.Add(DownloadURL, DownloadFileName, '');
    DownloadPage0.Show();
    try
      try
        DownloadPage0.Download();
      except
        result := false;
        if DownloadPage0.AbortedByUser then
          Msg := CustomMessage('DownloadPageAbortedByUser')
        else
          Msg := AddPeriod(GetExceptionMessage);
        if not WizardSilent() then
          Msgbox(Msg, mbCriticalError, MB_OK)
        else
          Log(Msg);
      end;
    finally
      DownloadPage0.Hide();
    end;
    if result then
    begin
      ZipFilePath := ExpandConstant(Format('{tmp}\%s', [DownloadFileName]));
      result := TestZipFile(ZipFilePath);
      if not result then
      begin
        ZipFilePath := '';
        Msg := CustomMessage('ZipFileNotValid');
        Log(Msg);
        if not WizardSilent() then
          MsgBox(Msg, mbCriticalError, MB_OK);
        exit;
      end;
    end;
  end;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo,
  MemoTypeInfo, MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: string): string;
var
  Info: string;
begin
  Info := '';
  if LatestVersionTag = '' then
  begin
    Info := Info + CustomMessage('ReadyMemoZipFileInfo') + NewLine + Space;
    Info := Info + ZipFilePath;
  end;
  // Show installation mode
  if Info <> '' then
    Info := Info + NewLine + NewLine;
  Info := Info + CustomMessage('ReadyMemoInstallSettings') + NewLine + Space;
  if LatestVersionTag <> '' then
    Info := Info + FmtMessage(CustomMessage('ReadyMemoInstallOnline'), [LatestVersionTag])
  else
    Info := Info + CustomMessage('ReadyMemoInstallOffline');
  Info := Info + NewLine + Space;
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

// Param parameter is required
function GetListenAddress(Param: string): string;
begin
  if (Trim(ListenAddress) = '0.0.0.0') or (Trim(ListenAddress) = '::') then
    result := '127.0.0.1'
  else
    result := ListenAddress;
end;

// Param parameter is required
function GetListenPort(Param: string): string;
begin
  result := ListenPort;
end;

// Param parameter is required
function GetUninstallDisplayName(Param: string): string;
begin
  result := ExpandConstant('{#AppName} ');
  if not IsAdminInstallMode() then
    result := result + CustomMessage('UninstallDisplayNamePerUserSuffix')
  else
    result := result + CustomMessage('UninstallDisplayNameServiceSuffix');
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
  Params := '--stop "{#ServiceName}"';
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
  FileName := ExpandConstant('{app}\asmt.exe');
  Params := ExpandConstant('--init'
    + ' --account="' + ServiceAccountUserName + '"'
    + ' --accountdescription="{cm:ServiceAccountDescription}"'
    + ' --name="{#ServiceName}"'
    + ' --displayname="{cm:ServiceDisplayName}"'
    + ' --description="{cm:ServiceDescription}"'
    + ' --commandline="""{app}\shawl.exe"" run --cwd ""{app}"" --no-log --priority below-normal --restart-if 3,4 --stop-timeout {#ServiceShutdownTimeout} --'
    + ' ""{app}\syncthing.exe"" --home ""{autoappdata}\{#AppName}"" --no-browser --no-restart"'
    + ' --starttype=');
  if WizardIsTaskSelected('startatboot') then
    Params := Params + 'DelayedAuto'
  else
    Params := Params + 'Demand';
  result := ExecEx(FileName, Params, true);
end;

function SetAppDataDirectoryPermissions(): Integer;
var
  TargetPath, FileName, Params: string;
begin
  // icacls to reset permissions
  TargetPath := ExpandConstant('{autoappdata}\{#AppName}');
  FileName := ExpandConstant('{sys}\icacls.exe');
  Params := '"' + TargetPath + '" /reset /t';
  ExecEx(FileName, Params, true);
  // Grant only SYSTEM, Administrators, and service account
  Params := '"' + TargetPath + '" /inheritance:r'
    + ' /grant "*S-1-5-18:(OI)(CI)F"'      // S-1-5-18 = SYSTEM
    + ' /grant "*S-1-5-32-544:(OI)(CI)F"'  // S-1-5-32-544 = Administrators
    + ' /grant "' + ServiceAccountUserName + ':(OI)(CI)M"';
  result := ExecEx(FileName, Params, true);
  // attrib to set app data directory and files to "not content indexed"
  // (strangely, "+i" means "not content indexed")
  FileName := ExpandConstant('{sys}\attrib.exe');
  Params := '+i "' + TargetPath + '"';
  ExecEx(FileName, Params, true);
  Params := '+i "' + TargetPath + '\*" /s /d';
  ExecEx(FileName, Params, true);
end;

function SetAppDirectoryPermissions(): Integer;
var
  TargetPath, FileName, Params: string;
begin
  TargetPath := ExpandConstant('{app}');
  // Reset permissions
  FileName := ExpandConstant('{sys}\icacls.exe');
  Params := '"' + TargetPath + '" /reset /t';
  ExecEx(FileName, Params, true);
  // Grant permissions to service account
  Params := '"' + TargetPath + '" /grant "' + ServiceAccountUserName + ':(OI)(CI)M"';
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

function DisableServiceAccountAndRemoveService(): Integer;
var
  FileName, Params: string;
begin
  FileName := ExpandConstant('{app}\asmt.exe');
  Params := ExpandConstant('--remove'
    + ' --name="{#ServiceName}"'
    + ' --account="' + ServiceAccountUserName + '"');
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
    InstalledSetupVersion := GetIniString('Setup', 'Version', '', ExpandConstant('{app}\{#IniFileName}'));
    if (InstalledSetupVersion = '') or
      (CompareVersionStrings(InstalledSetupVersion, '{#UninstallIfSetupVersionOlderThan}') < 0) then
    begin
      // Uninstall if:
      // Package is installed AND
      //   Can't get setup version from SetupVersion.ini, OR
      //   Version in SetupVersion.ini is older than {#UninstallIfVersionOlderThan}
      Log(CustomMessage('PrepareToInstallUninstallNeeded'));
      if UninstallISPackage() = 0 then
        Log(CustomMessage('PrepareToInstallUninstallSucceeded'))
      else
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
    if not IsAdminInstallMode() then
    begin
      if IsSyncthingRunning() then
        ExecEx(ExpandConstant('{app}\stctl.exe'), '--stop -q', true);
    end
    else
    begin
      if ServiceRunning() then
        StopService();
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  Version, Params, FileName: string;
begin
  if CurStep = ssPostInstall then
  begin
    ExecEx(ExpandConstant('{tmp}\unzip.exe'),
      ExpandConstant(Format('-jo -d "{app}" "%s" {#UnzipPattern}', [ZipFilePath])), true);
    if GetVersionNumbersString(ExpandConstant('{app}\syncthing.exe'), Version) then
    begin
      Log(FmtMessage(CustomMessage('InstalledVersion'), [Version]));
      SetIniString('InstalledVersion', 'Version', Version, ExpandConstant('{app}\{#IniFileName}'));
    end;
    if IsAdminInstallMode() then
    begin
      InstallOrResetService();
      SetAppDirectoryPermissions();
      SetAppDataDirectoryPermissions();
    end
    else
    begin
      if WizardIsTaskSelected('startatlogon') then
      begin
        Params := '/create /silent';
        if WizardIsTaskSelected('startatlogon\acpoweronly') then
          Params := Params + ' /startonacpoweronly';
      end
      else
      begin
        Params := '/remove /silent';
      end;
      ExecEx(ExpandConstant('{sys}\cscript.exe'), ExpandConstant('"{app}\{#ScriptNameSyncthingLogonTask}" ') + Params, true);
    end;
    SetupConfiguration();
    if WizardIsTaskSelected('startafterinstall') then
    begin
      ExecEx(ExpandConstant('{app}\stctl.exe'), '--start -q', true);
    end
    else if WizardIsTaskSelected('startserviceafterinstall') then
    begin
      if ServiceExists() and (not ServiceRunning()) then
        StartService();
    end;
    if not WizardIsTaskSelected('desktopicon') then
    begin
      FileName := ExpandConstant('{autodesktop}\{cm:ShortcutNameConfigurationPage}.lnk');
      if FileExists(FileName) then
      begin
        if DeleteFile(FileName) then
          Log(FmtMessage(CustomMessage('FileDeleteSucceeded'), [FileName]))
        else
          Log(FmtMessage(CustomMessage('FileDeleteFailed'), [FileName]));
      end;
    end;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    if IsAdminInstallMode() then
    begin
      if ServiceRunning() then
        StopService();
      DisableServiceAccountAndRemoveService();
    end
    else
    begin
      ExecEx(ExpandConstant('{app}\stctl.exe'), '--stop -q', true);
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

procedure DeinitializeUninstall();
var
  AppDir: string;
begin
  // Try to remove {app} at uninstall if it still exists
  AppDir := ExpandConstant('{app}');
  if DirExists(AppDir) then
  begin
    if RemoveDir(AppDir) then
      Log(FmtMessage(CustomMessage('DeinitializeUninstallAppDirRemoveSucceeded'), [AppDir]))
    else
      Log(FmtMessage(CustomMessage('DeinitializeUninstallAppDirRemoveFailed'), [AppDir]));
  end;
end;
