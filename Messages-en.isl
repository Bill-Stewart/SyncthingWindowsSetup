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
; [Run]
RunStatusMsg=Completing setup tasks...
RunPostInstallStartDescription=&Start Syncthing
RunPostInstallStartServiceDescription=&Start Syncthing service
; Network configuration page
NetConfigPageCaption=Select GUI Configuration Page Settings
NetConfigPageDescription=How should the GUI configuration page network settings be configured?
NetConfigPageSubCaption=NOTE: Please read the Syncthing documentation before changing these settings from the defaults.%n%nSpecify the GUI configuration page network settings, then click Next.
NetConfigPageItem0=Listen &address (default is 127.0.0.1):
NetConfigPageItem1=Listen &port (default is 8384):
NetConfigPageItem0Empty=The listen address cannot be empty. Please specify a listen address.
NetConfigPageItem1Empty=The listen port cannot be empty. Please specify a listen port.
NetConfigPageItem1NotValid=The listen port must be in the range 1024 through 65535.
; Ready memo page
ReadyMemoInstallInfo=Installation mode:
ReadyMemoInstallAdmin=Install for all users as Windows service
ReadyMemoInstallCurrentUser=Install for current user (%1)
ReadyMemoNetConfigInfo=GUI configuration page settings:
ReadyMemoNetConfigItem0=Listen address is
ReadyMemoNetConfigItem1=Listen port is
; Misc.
RunCommandMessage=Run command: "%1" %2
