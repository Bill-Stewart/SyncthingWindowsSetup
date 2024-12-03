#preproc ispp

; File encoding: UTF-8 with byte-order marker (BOM)

[Messages]
PrivilegesRequiredOverrideTitle=Select Setup Install Mode
PrivilegesRequiredOverrideInstruction=Select install mode
PrivilegesRequiredOverrideText1=%1 can be installed for all users as a Windows service (requires administrative privileges), or for the current user only.
PrivilegesRequiredOverrideText2=%1 can be installed for the current user only, or for all users as a Windows service (requires administrative privileges).
PrivilegesRequiredOverrideAllUsers=Install for &all users as a Windows service
PrivilegesRequiredOverrideAllUsersRecommended=Install for &all users as a Windows service (recommended)
PrivilegesRequiredOverrideCurrentUser=Install for &current user only
PrivilegesRequiredOverrideCurrentUserRecommended=Install for &current user only (recommended)
FinishedLabel=Setup has finished installing [name] on your computer.

[CustomMessages]
; Uninstall display
UninstallDisplayNamePerUserSuffix=(Current user)
UninstallDisplayNameServiceSuffix=(Service)
; Service account
ServiceAccountDescription=Syncthing service account
; Service
ServiceDisplayName=Syncthing Service
ServiceDescription=Syncthing securely synchronizes files between two or more computers in real time.
; [Icons]
ShortcutNameConfigurationPage=Syncthing Configuration Page
ShortcutNameConfigurationPageComment=Opens the Syncthing configuration web page.
ShortcutNameStartSyncthing=Start Syncthing
ShortcutNameStartSyncthingComment=Starts Syncthing.
ShortcutNameStopSyncthing=Stop Syncthing
ShortcutNameStopSyncthingComment=Stops Syncthing.
; [Tasks]
TasksStartAtBoot=Start Syncthing service &automatically when system boots
TasksStartServiceAfterInstall=Start Syncthing service after &installation
TasksStartAtLogon=Start Syncthing &automatically when logging on
TasksStartAtLogon_ACPowerOnly=S&tart automatically only if the computer is running AC power
TasksStartAfterInstall=Start Syncthing after &installation
TasksCreateDesktopIcon=Create &desktop shortcut for Syncthing configuration page
; [Run]
RunStatusMsg=Completing setup tasks...
RunPostInstallOpenConfigPage=&Open Syncthing configuration page
; Initialization
InitializeSetupError0=Setup initialization error: Installation for all users is not permitted on a domain controller.%n%nSetup will now exit.
InitializeSetupError1=Setup initialization error: WSH script registration is not valid.%n%nTo correct this issue, please see the "Setup Initalization Errors" section in the documentation.%n%nSetup will now exit.
InitializeSetupError2=Setup initialization error: Administrative installation detected.%n%nSetup has detected that an administrative installation is already installed. To reinstall, please restart Setup with the /ALLUSERS command line option.%n%nSetup will now exit.
InitializeSetupWarning0=Warning: Unable to retrieve latest version information from github.com.
; Memo pages
MemoPage0Caption=License
MemoPage0Description=Please see below for license information.
MemoPage0SubCaption=When you are ready to continue with Setup, click Next.
; File pages
FilePage0Caption=Select Installation Zip File
FilePage0Description=Which zip file should Setup use to install Syncthing?
FilePage0SubCaption=Specify the location of the installation zip file, then click Next.
FilePage0Prompt=Syncthing &installation zip file:
FilePage0Filter=Zip files (*.zip)|*.zip|All files (*)|*
; File page errors
FilePage0Item0Empty=You must specify the path to the Syncthing zip file.
; Configuration pages
ConfigPage0Caption=Select Configuration Settings
ConfigPage0Description=How should Setup configure Syncthing?
ConfigPage0SubCaption=Specify Syncthing configuration settings, then click Next.
ConfigPage0Item0=Automatic &upgrade interval, in hours (0 to disable; default is %1):
ConfigPage0Item1=GUI configuration page listen &address (default is %1):
ConfigPage0Item2=GUI configuration page listen &port (default is %1):
ConfigPage0Item3=Relays enabled ('false' or 'true', default is '%1'):
; Configuration page errors
ConfigPage0Item0NotValid=The automatic upgrade interval must be in the range 0 through 65535.
ConfigPage0Item1Empty=You must specify a listen address.
ConfigPage0Item2NotValid=The listen port must be in the range 1024 through 65535.
ConfigPage0Item3NotValid=The relays value must be 'false' or 'true'.
; Download pages
DownloadPageAbortedByUser=Download aborted.
; Ready memo page
ReadyMemoZipFileInfo=Installation zip file location:
ReadyMemoInstallSettings=Installation settings:
ReadyMemoInstallOnline=Online installation (download and install %1)
ReadyMemoInstallOffline=Offline installation (use installation zip file)
ReadyMemoInstallAdmin=Install for all users as Windows service
ReadyMemoInstallAdminServiceAccountUserName=Service account user name: %1
ReadyMemoInstallCurrentUser=Install for current user (%1)
ReadyMemoConfigInfo=Configuration settings:
ReadyMemoConfigItem0Disabled=Automatic upgrades are disabled
ReadyMemoConfigItem0Enabled=Automatic upgrade check occurs every %1 hours
ReadyMemoConfigItem1=GUI configuration page listen address is
ReadyMemoConfigItem2=GUI configuration page listen port is
ReadyMemoConfigItem3Disabled=Relays are disabled
ReadyMemoConfigItem3Enabled=Relays are enabled
; Preparing to Install page
PrepareToInstallUninstallNeeded=Setup has detected it should uninstall the currently installed version.
PrepareToInstallUninstallSucceeded=Setup successfully uninstalled the currently installed version.
; Preparing to Install errors
PrepareToInstallErrorMessage0=Setup was unable to uninstall the version currently installed on the system. To perform an upgrade, you must uninstall the old version that is currently installed before you will be able to install this version.
PrepareToInstallErrorMessage1=Setup has detected that the installed version (%1) is newer than this version (%2). To perform a downgrade, first uninstall the installed version, and then install this version.
; DeinitializeUninstall
DeinitializeUninstallAppDirRemoveSucceeded=Removed directory: %1
DeinitializeUninstallAppDirRemoveFailed=Failed to remove directory: %1
; Misc.
RunCommandMessage=Run command: "%1" %2
ProcessCheckSucceededRunning=FindProcess function in ProcessCheck.dll succeeded; "%1" is running
ProcessCheckSucceededNotRunning=FindProcess function in ProcessCheck.dll succeeded; "%1" is not running
ProcessCheckFailed=FindProcess function in ProcessCheck.dll failed
InstallTypeNotInstalled=The package is not detected as installed.
InstallTypeAdmin=The package is detected as installed in administrative installation mode.
InstallTypeNonAdmin=The package is detected as installed in non administrative installation mode.
DownloadFileSucceeded=Download succeeded
ZipFilePathFound=The specified zip file was found.
ZipFilePathNotFound=The specified zip file was not found.
ZipFileNotValid=The specified zip file is not valid.
InstalledVersion=Successfully installed version %1
FileDeleteSucceeded=Deleted file: %1
FileDeleteFailed=Failed to delete file: %1
