#preproc ispp

; File encoding: UTF-8 with byte-order marker (BOM)

[Messages]
PrivilegesRequiredOverrideTitle=Select Setup Install Mode
PrivilegesRequiredOverrideInstruction=Select install mode
PrivilegesRequiredOverrideText1=%1 can be installed for all users (requires administrative privileges), or for the current user only.
PrivilegesRequiredOverrideText2=%1 can be installed for the current user only, or for all users (requires administrative privileges).
PrivilegesRequiredOverrideAllUsers=Install for &all users
PrivilegesRequiredOverrideAllUsersRecommended=Install for &all users
PrivilegesRequiredOverrideCurrentUser=Install for &current user only
PrivilegesRequiredOverrideCurrentUserRecommended=Install for &current user only
FinishedLabel=Setup has finished installing [name] on your computer.

[CustomMessages]
; Service account
ServiceAccountDescription=Syncthing service account
; Service
ServiceDisplayName=Syncthing Service
ServiceDescription=Syncthing securely synchronizes files between two or more computers in real time.
; [Icons]
ShortcutNameConfigurationPage=Syncthing Configuration Page
ShortcutNameConfigurationPageComment=Opens the Syncthing configuration web page.
ShortcutNameConfigureService=Configure Syncthing Service
ShortcutNameConfigureServiceComment=Configures the Syncthing Windows service using NSSM (recommended for advanced users only).
ShortcutNameStartSyncthing=Start Syncthing
ShortcutNameStartSyncthingComment=Starts Syncthing as the current user.
ShortcutNameStopSyncthing=Stop Syncthing
ShortcutNameStopSyncthingComment=Stops Syncthing.
; [Tasks]
TasksStartAtBoot=&Start Syncthing service automatically when system boots
TasksStartAtLogon=&Start Syncthing automatically when logging on
; [Run]
RunStatusMsg=Completing setup tasks...
RunPostInstallStartServiceDescription=&Start Syncthing service
RunPostInstallStartDescription=&Start Syncthing
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
; Ready memo page
ReadyMemoInstallInfo=Installation mode:
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
; Configuration migration messages
MigrationNeededMessage=Setup has detected that the Syncthing configuration should be migrated from "%1" to "%2"
MigrationSucceededMessage=Setup successfully migrated the Syncthing configuration from "%1" to "%2"
MigrationFailedMessage=Setup failed to migrate the Syncthing configuration from "%1" to "%2"
MigratedConfigFlagFileText=This Syncthing configuration has been migrated to the following folder:%n%n%1
MigratedConfigRemoveOldInstruction=Remove the legacy Syncthing configuration folder?
MigratedConfigRemoveOldText=Setup has successfully migrated the following legacy Syncthing configuration folder:%n%n%1%n%nThe Syncthing configuration is now stored in the following folder:%n%n%2%n%nShould Setup remove the legacy Syncthing configuration folder?
MigratedConfigRemoveOldButton1=&Remove the legacy configuration folder (recommended)
MigratedConfigRemoveOldButton2=&Do not remove the legacy configuration folder
MigratedConfigRemoveSuccess=Removed migrated configuration folder "%1"
MigratedConfigRemoveFailure=Failed to remove migrated configuration folder "%1"
; Misc.
RunCommandMessage=Run command: "%1" %2
