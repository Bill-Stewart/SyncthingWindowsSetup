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
; Service display names
ServiceDisplayName=Syncthing Service
ServiceDescription=Syncthing securely synchronizes files between two or more computers in real time.
; [Icons]
ShortcutNameFAQ=FAQ
ShortcutNameGettingStarted=Getting Started
ShortcutNameConfigurationPage=Syncthing Configuration Page
ShortcutNameConfigurationPageComment=Opens the Syncthing configuration web page.
ShortcutNameConfigureService=Configure Syncthing Service
ShortcutNameConfigureServiceComment=Configures the Syncthing Windows service using NSSM (recommended for advanced users only).
ShortcutNameStartSyncthing=Start Syncthing
ShortcutNameStartSyncthingComment=Starts Syncthing as the current user.
ShortcutNameStopSyncthing=Stop Syncthing
ShortcutNameStopSyncthingComment=Stops Syncthing.
; [Tasks]
TasksAllowAutoUpgradeDescription=Allow Syncthing to &upgrade automatically
TasksStartAtBoot=&Start Syncthing service automatically when system boots
TasksStartAtLogon=&Start Syncthing automatically when logging on
; [Run]
RunStatusMsg=Completing setup tasks...
RunPostInstallStartDescription=&Start Syncthing
RunPostInstallStartServiceDescription=&Start Syncthing service
; Configuration page
ConfigPageCaption=Select Configuration Settings
ConfigPageDescription=How should Setup configure Syncthing?
ConfigPageSubCaption=Specify Syncthing configuration settings, then click Next.
ConfigPageItem0=Automatic &upgrade interval, in hours (0 to disable; default is %1):
ConfigPageItem1=GUI configuration page listen &address (default is %1):
ConfigPageItem2=GUI configuration page listen &port (default is %1):
; Configuration page errors
ConfigPageItem0NotValid=The automatic upgrade interval must be in the range 0 through 65535.
ConfigPageItem1Empty=The listen address cannot be empty. Please specify a listen address.
ConfigPageItem2NotValid=The listen port must be in the range 1024 through 65535.
; Ready memo page
ReadyMemoInstallInfo=Installation mode:
ReadyMemoInstallAdmin=Install for all users as Windows service
ReadyMemoInstallCurrentUser=Install for current user (%1)
ReadyMemoConfigInfo=Configuration settings:
ReadyMemoConfigItem0Enabled=Automatic upgrade check occurs every %1 hours
ReadyMemoConfigItem0Disabled=Automatic upgrades are disabled
ReadyMemoConfigItem1=GUI configuration page listen address is
ReadyMemoConfigItem2=GUI configuration page listen port is
; Misc.
RunCommandMessage=Run command: "%1" %2
