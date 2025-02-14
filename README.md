<!-- omit in toc -->
# Syncthing Windows Setup

Syncthing Windows Setup is a lightweight yet full-featured Windows installer for the open-source [Syncthing](https://syncthing.net) file-synchronization application.

---

<!-- omit in toc -->
## Table of Contents

- [System Requirements](#system-requirements)
- [Download](#download)
- [Background](#background)
- [Version History](#version-history)
- [Upgrade Details](#upgrade-details)
- [Downgrading an Installation](#downgrading-an-installation)
- [Changing Installation Type](#changing-installation-type)
- [Setup Initialization Errors](#setup-initialization-errors)
  - [Installation for All Users not Allowed on Domain Controllers](#installation-for-all-users-not-allowed-on-domain-controllers)
  - [Invalid WSH Script Registration](#invalid-wsh-script-registration)
  - [Administrative Installation Detected](#administrative-installation-detected)
- [Setup Command Line Parameters](#setup-command-line-parameters)
- [Offline Installation](#offline-installation)
- [Non Administrative vs. Administrative Installation Mode](#non-administrative-vs-administrative-installation-mode)
  - [Non Administrative (Current User) Installation Mode](#non-administrative-current-user-installation-mode)
  - [Administrative (All Users) Installation Mode](#administrative-all-users-installation-mode)
    - [Windows Service Installation](#windows-service-installation)
    - [Local User Service Account Considerations](#local-user-service-account-considerations)
    - [Granting Folder Permissions for the Service Account](#granting-folder-permissions-for-the-service-account)
- [Setup Tasks](#setup-tasks)
- [Start Menu Shortcuts](#start-menu-shortcuts)
- [Managing Automatic Startup](#managing-automatic-startup)
  - [Managing Automatic Startup for the Current User](#managing-automatic-startup-for-the-current-user)
  - [Managing Automatic Startup for the Windows Service (All Users)](#managing-automatic-startup-for-the-windows-service-all-users)
- [Checking If Syncthing Is Running](#checking-if-syncthing-is-running)
  - [Checking if Syncthing is Running for the Current User](#checking-if-syncthing-is-running-for-the-current-user)
  - [Checking if Syncthing is Running as a Service](#checking-if-syncthing-is-running-as-a-service)
- [Windows Firewall Rules](#windows-firewall-rules)
  - [Firewall Rule Creation](#firewall-rule-creation)
  - [Creating the Firewall Rule Manually](#creating-the-firewall-rule-manually)
  - [Firewall Rule Removal](#firewall-rule-removal)
  - [Removing the Firewall Rule Manually](#removing-the-firewall-rule-manually)
- [Helper Tools](#helper-tools)
- [Resetting the Service Account Password](#resetting-the-service-account-password)
- [Finding the Syncthing Configuration Folder](#finding-the-syncthing-configuration-folder)
- [Uninstalling Syncthing](#uninstalling-syncthing)
- [Silent Install and Uninstall](#silent-install-and-uninstall)
  - [Silent Non Administrative (Current User) Installation](#silent-non-administrative-current-user-installation)
  - [Silent Administrative (All Users) Installation](#silent-administrative-all-users-installation)
  - [Silent Uninstall](#silent-uninstall)
- [Reporting Problems](#reporting-problems)
- [Acknowledgments](#acknowledgments)

---

## System Requirements

Syncthing Windows Setup has the same requirements as Syncthing itself: Windows 10 or Windows Server 2016 or later.

## Download

You can download the latest version of Syncthing Windows Setup from the Github Releases page:

https://github.com/Bill-Stewart/SyncthingWindowsSetup/releases/latest/

## Background

Syncthing Windows Setup (herein referred to as "Setup") provides a [Syncthing](https://syncthing.net/) installer for Windows, built using [Inno Setup](https://www.jrsoftware.org/isinfo.php). It provides the following features:

* Downloads and installs the latest version of Syncthing from GitHub

* Supports offline installation for Windows-based computers that can't connect to GitHub (see [Offline Installation](#offline-installation))

* Supports non administrative (current user) and administrative (all users) installation (see [Non Administrative vs. Administrative Installation Mode](#non-administrative-vs-administrative-installation-mode))

* When installing for the current user (the default), Setup creates a scheduled task that starts Syncthing at logon (if selected)

* When installing for all users, installs Syncthing as a Windows service (see [Windows Service Installation](#windows-service-installation))

* Supports adding a Windows Firewall rule for Syncthing (see [Windows Firewall Rules](#windows-firewall-rules))

* Installs a set of helper tools for ease-of-use (see [Helper Tools](#helper-tools))

* Supports silent (hands-free) installation (see [Silent Install and Uninstall](#silent-install-and-uninstall))

* Allows localization of Setup and scripts (see `building.md` file for details)

## Version History

See `history.md`.

## Upgrade Details

Administrative installations in versions 1.19.1 and older configured the Windows service to run using the Windows built-in **LocalService** account. To improve security, Setup versions newer than 1.19.1 configure the Windows service to run using a local service user account instead (**SyncthingServiceAcct** by default). As a part of this change, the Syncthing configuration data is now located in the _CommonAppData_`\Syncthing` folder (e.g., `C:\ProgramData\Syncthing`).

If you upgrade an administrative installation from version 1.19.1 or older, Setup version 1.27.0 and newer will uninstall the old version and install the new version, but it will no longer migrate the configuration data. Because of this change, it is recommended to first upgrade to version 1.26.1 to migrate the configuration data, and then upgrade again to version 1.27.0 or later.

Starting in version 1.27.11, Setup automatically downloads and installs the latest version of Syncthing for Windows from GitHub. If Setup can't connect to GitHub, you must perform an offline installation (see [Offline Installation](#offline-installation)).

## Downgrading an Installation

To downgrade a Syncthing installation, do the following:

1. Disable Syncthing's automatic upgrade setting.

2. Stop Syncthing.

3. Manually replace the `syncthing.exe` file with your preferred version.

4. Start Syncthing.

> NOTE: If you run Setup to reinstall or upgrade Syncthing, the **Automatic upgrade interval** setting on the **Select Configuration Settings** wizard page (or the `/autoupgradeinterval` command-line parameter) will override the **Automatic Upgrades** setting in the Syncthing configuration GUI.

## Changing Installation Type

If you installed using non administrative (current user) installation mode and want to use administrative (all users) installation mode instead (or vice versa), you must uninstall and reinstall using your preferred installation mode.

If you want to keep the same configuration, you will need to replace the content of the Syncthing configuration folder. The location of the Syncthing configuration folder depends on the installation mode; see [Finding the Syncthing Configuration Folder](#finding-the-syncthing-configuration-folder) for details.

## Setup Initialization Errors

This section discusses potential errors that may occur during Setup's initialization phase that will abort the installation process.

### Installation for All Users not Allowed on Domain Controllers

For various reasons, Setup does not permit installation for all users (i.e., the Windows service) on Active Directory domain controller servers. If you need to run Syncthing on domain controllers, this author's recommendation is to run `syncthing.exe` using a Group Managed Service Account (gMSA). See Microsoft's documentation for more information about gMSAs.

### Invalid WSH Script Registration

Setup uses Windows Script Host (WSH) scripts to perform a number of tasks. On some computers, the WSH script registration for JScript (`.js`) files on the computer is missing or incorrect. To ensure it can complete successfully, Setup checks for the following value in the registry:

Path: `HKEY_CLASSES_ROOT\.js`  
Default value: `JSFile`

Setup will abort if this registry value is not correct. To fix this problem, use whatever tool you prefer (e.g., the Windows Registry Editor) to correct the default value at this registry location to `JSFile`. For example, you can run the following command from an elevated command line (cmd.exe or PowerShell) window:

    reg add "HKCR\.js" /ve /d "JSFile"

### Administrative Installation Detected

If Setup detects that the package is installed in administrative (all users) installation mode and you did not specify the `/allusers` parameter on Setup's command line, it will abort the installation and instruct the user to restart setup with the `/allusers` parameter.

## Setup Command Line Parameters

The following table lists the most common Setup command line parameters:

Parameter                                | Description
---------                                | -----------
`/currentuser`                           | Runs Setup in non-administrative (current user) installation mode (see [Non Administrative vs. Administrative Installation Mode](##non-administrative-vs-administrative-installation-mode)). This is the default and is recommended for most users.
`/allusers`                              | Runs Setup in administrative (all users) installation mode (see [Non Administrative vs. Administrative Installation Mode](##non-administrative-vs-administrative-installation-mode)). This installs the Windows service and is recommended for more advanced users. NOTE: You must specify this parameter if performing a reinstall in administrative (all users) installation mode, even if the package is already installed.
`/dir="`_location_`"`                    | Specifies the installation folder. The default installation folder depends on whether Setup runs in administrative (all users) or non administrative (current user) installation mode.
`/group="`_name_`"`                      | Specifies the Start Menu group name. The default group name is **Syncthing**.
`/tasks="`_task_[`,`_task_[...]]`"`      | Selects one or more tasks on the **Select Additional Tasks** wizard page (see [Setup Tasks](#setup-tasks)).
`/mergetasks="`_task_[`,`_task_[...]]`"` | Like `/tasks`, except Setup merges the specified tasks with the set of tasks that would have otherwise been selected by default.
`/noicons`                               | Prevents creation of a Start Menu group.
`/silent`                                | Runs Setup without requiring user interaction (see [Silent Install and Uninstall](#silent-install-and-uninstall)).
`/log="`_filename_`"`                    | Logs Setup activity to the specified file. The default is not to create a log file.

See [Inno Setup's documentation](https://jrsoftware.org/ishelp/index.php?topic=setupcmdline) for more details about the above parameters.

In addition to the standard Inno Setup parameters, Setup also supports some custom command line parameters. The parameters marked with **[*]** correspond to the settings on the **Select Configuration Settings** page in Setup.

Parameter                            | Description
---------                            | -----------
`/autoupgradeinterval=`_interval_    | **[*]** Specifies the number of hours that Syncthing should check for upgrades and automatically upgrade itself. The default value is 12 hours. Specify **0** to disable Syncthing's automatic upgrade feature.
`/listenaddress=`_address_           | **[*]** Specifies the listen address for the web GUI configuration page. The default listen address is **127.0.0.1**.
`/listenport=`_port_                 | **[*]** Specifies the TCP port number for the web GUI configuration page. The default port number is **8384**.
`/relaysenabled=`_value_             | **[*]** Specifies whether relays are enabled (_value_ must be either **true** or **false**). The default value is **true** (i.e., relays are enabled).
`/serviceaccountusername=`_username_ | For administrative installation mode, specifies the local service user account user name. The default user name is **SyncthingServiceAcct**.
`/noconfigpage`                      | Prevents the **Open Syncthing configuration page** checkbox from appearing on the final Setup wizard page.
`/zipfilepath="`_filename_`"`        | Specifies the path and filename of the zip file Setup uses to extract the Syncthing files (see [Offline Installation](#offline-installation)).

Please note the following:

* The `/autoupgradeinterval` parameter affects the `syncthing.exe` executable only (it does not download or run a new version of Setup). If this setting is greater than 0 and Syncthing detects a new version released by the Syncthing team on the Internet, Syncthing will upgrade itself. (The Syncthing configuration GUI also allows enabling or disabling automatic upgrading, but reinstalling or upgrading Syncthing using Setup will override the configuration GUI setting.)

* Please read the [Syncthing documentation page about the GUI listen address](https://docs.syncthing.net/users/guilisten.html) before changing the listen address and port numbers from the defaults.

* For more information about relays, please see the [Syncthing documentation page about relaying](https://docs.syncthing.net/users/relaying). Please note that relaying might trigger network security alerts if an outgoing connection is made to a relay network host on the Internet that is being shared by a network service prohibited by network security teams on business or government networks. It is recommended to check with network security teams before using Syncthing on these kinds of networks.

* It is recommended not to use the `/serviceaccountusername` parameter to change the local service account user name except in the extremely rare case that the username is already in use.

## Offline Installation

For Windows-based computers that are unable to download files from GitHub using https, Setup supports offline installation. To facilitate offline installation, you must download the zip file for the Windows version of Syncthing from a separate computer that can connect to GitHub. You can download the latest version of the zip file from the Syncthing project's **Releases** page:

https://github.com/syncthing/syncthing/releases/latest

The zip file uses the following format:

`syncthing-windows-`_platform_`-v`_version_`.zip`

Where:

*  _platform_ is one of the following: **amd64**, **386**, or **arm64**

* _version_ is the Syncthing version number

For example: `syncthing-windows-amd64-v1.27.11.zip` (**amd64** is the most common version)

Once you have the zip file, you can specify it for Setup by doing one of the following:

* Select the installation zip file on the **Select Installation Zip File** wizard page in Setup, or

* Specify the full path and filename of the installation zip file using the **/zipfilepath** parameter on Setup's command line (see [Setup Command Line Parameters](#setup-command-line-parameters)).

Please note the following behaviors:

* If Setup can't connect to GitHub to retrieve the latest Syncthing version information, it will assume an offline installation and display the **Select Installation Zip File** wizard page.

* If you specify the **/zipfilepath** parameter, Setup will not attempt to connect to GetHub to retrieve Syncthing version information or download the latest installation zip file.

## Non Administrative vs. Administrative Installation Mode

By default, Setup installs Syncthing for the current user only. This is recommeded for most users.

If you want to install Syncthing as a Windows service (recommended for more advanced users), you must specify the `/allusers` parameter on Setup's command line (see [Setup Command Line Parameters](#setup-command-line-parameters)). This parameter is also required if you want to reinstall the service.

> NOTE: Installing in administrative (all users) installation mode means you must manually configure folder permissions to add folders to the Syncthing configuration (see [Granting Folder Permissions for the Service Account](#granting-folder-permissions-for-the-service-account)).

See below for the differences between the two modes.

### Non Administrative (Current User) Installation Mode

Non administrative (current user) installation mode is the default and is recommended for most users. The following notes apply to this installation mode:

* Setup installs Syncthing for the current user only

* The default installation folder is _LocalAppData_`\Programs\Syncthing` (where _LocalAppData_ is the current user's local application data folder; e.g., `C:\Users\UserName\AppData\Local`)

* The Syncthing configuration folder is _LocalAppData_`\Syncthing` (e.g., `C:\Users\UserName\AppData\Local`; see [Finding the Syncthing Configuration Folder](#finding-the-syncthing-configuration-folder))

* Setup does not install Syncthing as a Windows service

* By default, Setup creates a scheduled task that starts Syncthing in the background when the current user logs on; you can change this by deselecting the **Start Syncthing automatically when logging on** checkbox on the **Select Additional Tasks** wizard page

* Syncthing runs only when the installing user logs on

* Starting and stopping Syncthing is managed by [Start Menu shortcuts](#start-menu-shortcuts)

* Setup prompts to create a Windows Firewall rule for Syncthing (requires administrative permissions)

* By default, Setup starts Syncthing after installation completes if a firewall rule exists for it; you can change this by deselecting the **Start Syncthing after installation** checkbox on the **Select Additional Tasks** wizard page

* No folder permission changes are required to add the current user's folders to the Syncthing configuration

* Administrative permissions are not required to make changes to files in the Syncthing configuration folder

### Administrative (All Users) Installation Mode

Administrative (all users) installation mode installs Syncthing as a Windows service and is recommended only for more advanced users. The following notes apply to this installation mode:

* Setup installs Syncthing for all users of the computer

* The default installation folder is _ProgramFiles_`\Syncthing` (where _ProgramFiles_ is the system's `Program Files` folder; e.g., `C:\Program Files`)

* The Syncthing configuration folder is _CommonAppData_`\Syncthing` (e.g., `C:\ProgramData\Syncthing`; see [Finding the Syncthing Configuration Folder](#finding-the-syncthing-configuration-folder))

* Setup installs Syncthing as a Windows service (see [Windows Service Installation](#windows-service-installation))

* By default, Syncthing starts automatically when the system boots; you can change this by deselecting the **Start Syncthing service automatically when system boots** checkbox on the **Select Additional Tasks** wizard page

* Syncthing runs as a service and synchronizes folders even when no users are logged on

* Starting and stopping Syncthing is managed by stopping and starting the Windows service

* Setup automatically creates a Windows Firewall rule for Syncthing

* By default, Setup starts the Syncthing service after installation completes; you can change this by deselecting the **Start Syncthing service after installation** checkbox on the **Select Additional Tasks** wizard page

* You must manually grant folder permissions for folders you want to add to the Syncthing configuration (see [Granting Folder Permissions for the Service Account](#granting-folder-permissions-for-the-service-account))

* Administrative permissions are required to make changes to files in the Syncthing configuration folder

> NOTE: You must specify `/allusers` on Setup's command line to install or reinstall in administrative (all users) installation mode.

#### Windows Service Installation

When you run Setup in administrative (all users) installation mode, it installs Syncthing as a Windows service. The service runs using a local service account (**SyncthingServiceAcct** by default). By default, Setup configures the service to start at boot. You can change this default by deselecting the `startatboot` task when installing (see [Setup Tasks](#setup-tasks)).

#### Local User Service Account Considerations

In administrative installation mode, Setup setup creates or updates the local service user account (**SyncthingServiceAcct** by default) with a very long, random password and configures the following settings for the account:

* It sets the account's password not to expire

* It grants the account the **Log on as a service** user right

If the computer is joined to a domain, be aware that Group Policy Object (GPO) settings might override either or both of these settings for the local service user account, which can prevent the service from working. If GPO settings override either or both of these settings, you can do either of the following:

* Uninstall the administrative installation of Syncthing and install for the current user instead, or

* Update the relevant GPO(s) to prevent overriding of the setting(s).

#### Granting Folder Permissions for the Service Account

In administrative (all users) installation mode, Syncthing runs as a Windows service using a local service user account (**SyncthingServiceAcct** by default). Normally the local service user account does not have permissions to folders you want to synchronize using Syncthing. This means you must grant the local service user account "Modify" permissions to any folders specified in the Syncthing configuration.

You can grant the local service user account "Modify" permissions to a folder using the Windows File Explorer. Alternatively, you can run the **icacls** command from the command line; e.g.:

    icacls "C:\Users\username\Documents" /grant "SyncthingServiceAcct:(OI)(CI)M" /t

Of course, replace `C:\Users\username\Documents` with the correct folder name, and replace `SyncthingServiceAcct` with the correct service account user name if you changed the default service account user name.

Once the local service user account has "Modify" permissions for the folder, you can add it to the Syncthing configuration.

> NOTE: Granting folder permissions is normally only needed if you installed Syncthing in administrative (all users) installation mode.

## Setup Tasks

The **Select Additional Tasks** wizard page in Setup specifies additional tasks that Setup should perform, as described in the following table:

Task Description                                             | Name                       | Installation Mode
----------------                                             | ----                       | -----------------
Start Syncthing automatically when logging on                | `startatlogon`             | Current user
Start automatically only if the computer is running AC power | `startatlogon\acpoweronly` | Current user
Start Syncthing after installation                           | `startafterinstall`        | Current user
Start Syncthing service automatically when system boots      | `startatboot`              | All users
Start Syncthing service after installation                   | `startserviceafterinstall` | All users
Create desktop shortcut for Syncthing configuration page     | `desktopicon`              | Both

The `/tasks` and `/mergetasks` command line parameters (see [Setup Command Line Parameters](#setup-command-line-parameters)) allow you to select and deselect tasks using the command line. By default, all tasks are selected except for the following:

* `startatlogon\acpoweronly`
* `desktopicon`

Examples:

* Create a desktop shortcut in addition to all other tasks selected by default:

    `/mergetasks=desktopicon`

* For an administrative installation, do not start the Syncthing service after installation, but leave all other default tasks selected:

    `/mergetasks=!startserviceafterinstall`

* For a non administrative installation, specify only to start Syncthing at logon and do not select any other tasks:

    `/tasks=startatlogon`

* Remove the desktop shortcut during a reinstall and do not change the state of any other tasks:

    `/mergetasks=!desktopicon`

See [Inno Setup's documentation](https://jrsoftware.org/ishelp/index.php?topic=setupcmdline) for more details about the `/tasks` and `/mergetasks` command line parameters.

## Start Menu Shortcuts

Setup creates the following Start Menu shortcuts, depending on the [installation mode](#administrative-vs-non-administrative-installation-mode):

Shortcut                     | Installation Mode | Description
--------                     | ----------------- | -----------
Syncthing Configuration Page | Both              | Opens the Syncthing GUI configuration page using the default browser
Start Syncthing              | Current user      | Starts Syncthing in the background for the current user
Stop Syncthing               | Current user      | Stops the Syncthing instance running for the current user

* The **Syncthing Configuration Page** shortcut opens the `ConfigurationPage.url` file in the Syncthing installation folder (i.e., it opens the Syncthing GUI configuration page).

* The **Start Syncthing** and **Stop Syncthing** shortcuts run the `stctl.exe` tool to start and stop Syncthing (see [Helper Tools](#helper-tools)).

## Managing Automatic Startup

Setup configures Syncthing to start automatically by default, unless you deselect the `startatlogon` or `startatboot` task (see [Setup Tasks](#setup-tasks)). You can change this configuration after installation if needed. The steps for changing the configuration depends on whether you installed using non administrative (current user) or administrative (all users) or installation mode.

### Managing Automatic Startup for the Current User

If you installed Syncthing for the current user, Setup creates a scheduled task that starts Syncthing automatically when the current user logs on. Setup does not create this task if you deselect the `startatlogon` task (see [Setup Tasks](#setup-tasks)) when installing.

If you did not select the `startatlogon` task when installing and want to create the task, do either of the following:

* Run setup to reinstall Syncthing and select the `startatlogon` task (i.e., the **Start Syncthing automatically when logging on** checkbox on the **Select Additional Tasks** page).

OR

1. Open a command prompt or PowerShell window.

2. Run the following command:

       cscript "C:\Users\username\AppData\Local\Programs\Syncthing\SyncthingLogonTask.js" /create

    (where `C:\Users\username\appData\Local\Programs\Syncthing` is the Syncthing installation folder; replace `username` with the correct username)

If you want to disable the logon task instead, do the following:

1. Open the Windows Task Scheduler application.

2. Right-click the **Start Syncthing at logon (_username_)** task and choose **Disable**.

### Managing Automatic Startup for the Windows Service (All Users)

If you installed Syncthing for all users (i.e., the Windows service is installed), do the following:

* Run Setup with the `/allusers` parameter to reinstall Syncthing and select or deselect the `startatboot` task (i.e., the **Start Syncthing service automatically when system boots** checkbox on the **Select Additional Tasks** page).

OR

1. Open the Windows Services application.

2. Double-click the Syncthing service.

3. Change **Startup type** to **Automatic (Delayed Start)** or **Manual**, then Click **OK**.

Note that these steps require administrative permissions.

## Checking If Syncthing Is Running

This section describes how to check if Syncthing is running.

### Checking if Syncthing is Running for the Current User

If you ran Setup in non administrative (current user) mode, do one of the following:

1. Open the Windows Task Manager application.

2. Switch to the "details" view to see the list of running applications.

3. Check whether `syncthing.exe` is in the list.

OR

1. Open a command prompt or PowerShell window.

2. Enter the following command:

        tasklist /fi "imagename eq syncthing.exe"

   The output of this command will indicate whether Syncthing is currently running.

> NOTE: No matter whether you use the Task Manager application or the **tasklist** command, it is normal for there to be more than one running instance of `syncthing.exe`.

### Checking if Syncthing is Running as a Service

If you ran Setup in administrative (all users) installation mode, do the following:

1. Open the Windows Services application.

2. Find the Syncthing service in the list.

3. The **Status** column will indicate if the Syncthing service is running.

> NOTE: The **tasklist** command in the previous section also works to check if the service is running, except that the **Session Name** column in the output will contain _Services_ rather than _Console_.

## Windows Firewall Rules

Syncthing requires permission to communicate through the Windows Firewall. Creating and removing firewall rules requires administrative privileges.

### Firewall Rule Creation

* If you run Setup in non administrative (current user) installation mode, Setup prompts to create a firewall rule for Syncthing if it doesn't exist. Setup will prompt for administrative credentials (if needed).

* If you perform a silent install in non administrative installation mode (see [Setup Command Line Parameters](#setup-command-line-parameters)), Setup does not create a firewall rule for Syncthing, and you must create it manually (see [Creating the Firewall Rule Manually](#creating-the-firewall-rule-manually)).

* If you run Setup in administrative (all users) installation mode, Setup creates a firewall rule for Syncthing automatically.

### Creating the Firewall Rule Manually

If you ran Setup using non administrative installation mode and need to create a firewall rule for Syncthing manually, open a PowerShell or command prompt window and run the following command:

    cscript "C:\Users\username\AppData\Local\Programs\Syncthing\SyncthingFirewallRule.js" /create

(where `C:\Users\username\appData\Local\Programs\Syncthing` is the Syncthing installation folder; replace `username` with the correct username)

### Firewall Rule Removal

If you uninstall Syncthing (see [Uninstalling Syncthing](#uninstalling-syncthing)), the same considerations as above apply, except Setup removes the Syncthing firewall rule rather than creating it:

* An uninstall of a non administrative (current user) installation prompts to remove the Syncthing firewall rule if it exists (requires administrative permissions).

* A silent uninstall of a non administrative (current user) installation does not remove the Syncthing firewall rule, and you must to remove it manually. It is recommended to remove the firewall rule _before_ performing a silent uninstall if uninstalling for the current user (see [Removing the Firewall Rule Manually](#removing-the-firewall-rule-manually)).

* An uninstall of an administrative (all users) installation removes the Syncthing firewall rule automatically, without prompting.

### Removing the Firewall Rule Manually

If you installed using non administrative installation mode and need to remove the Syncthing firewall rule manually, open a PowerShell or command prompt window and run the following command:

    cscript "C:\Users\username\AppData\Local\Programs\Syncthing\SyncthingFirewallRule.js" /remove

(where `C:\Users\username\appData\Local\Programs\Syncthing` is the Syncthing installation folder; replace `username` with the correct username)

## Helper Tools

Setup installs a set of helper tools to the installation folder to facilitate ease-of-use, depending on the [installation mode](#administrative-vs-non-administrative-installation-mode), as described in the following table.

Tool                       | Installation Mode        | Description
------                     | -----------------        | -----------
`SetSyncthingConfig.js`    | Both                     | Setup uses this script to create and/or configure the Syncthing configuration file (`config.xml`).
`SyncthingFirewallRule.js` | Both                     | Adds, removes, and tests for the existence of a Windows Firewall rule for Syncthing (prompts for administrative permissions if required).
`SyncthingLogonTask.js`    | Current user (non admin) | Adds or removes a scheduled task that runs the `StartSyncthing.js` script at logon.
`stctl.exe`                | Current user (non admin) | Helper program for starting and stopping Syncthing for the current user.
`asmt.exe`                 | All users (admin)        | Helper program for installing and/or resetting the service account and service configuration.
`ServMan.exe`              | All users (admin)        | Helper program for starting and stopping the Syncthing service.
`shawl.exe`                | All users (admin)        | Helper program for running Syncthing as a Windows service.

## Resetting the Service Account Password

If you installed using administrative (all users) installation mode and want to reset the service account password, do the following:

1. Open a PowerShell or cmd.exe window as administrator

2. Change to the Syncthing installation folder; e.g. `cd "\Program Files\Syncthing"`

3. Run the following command:

    `.\asmt --reset --account=SyncthingServiceAcct --name=syncthing`

This command will reset the service account's password to a long, random password and update the Syncthing service to start with the new password.

> NOTE: If you changed the default service account username (not recommended), specify it after the `--account=` option.

## Finding the Syncthing Configuration Folder

The location of the Syncthing configuration folder depends on whether you run Setup in non administrative (current user) or administrative (all users) or installation mode:

* If you installed for the current user (the default), the Syncthing configuration folder is in the following location:

  _LocalAppData_`\Syncthing`

  where: _LocalAppData_ is the current user's local application data folder (e.g., `C:\Users\UserName\AppData\Local`)

  Administrative permissions are not required to access this folder.

* If you installed for all users (i.e., you specified the `/allusers` parameter on Setup's command line), the Syncthing configuration folder is in the following location:

    _CommonAppData_`\Syncthing`

  where: _CommonAppData_ is the common application data folder (e.g., `C:\ProgramData`)

  Administrative permissions are required to access this folder.

## Uninstalling Syncthing

You can uninstall Syncthing using the standard Windows application management list.

If you installed Syncthing in non administrative installation mode (current user only), the uninstall process prompts to remove the Syncthing firewall rule if it exists (this requires administrative permissions).

If you installed syncthing in administrative install mode, note that the uninstall process:

* Removes the Syncthing firewall rule

* Revokes the **Log on as a service** user right from the local service user account

* Disables (but does not delete) the local service user account

Regardless of whether you installed Syncthing in administrative or non administrative mode, the uninstall process does not remove any Syncthing configuration files. If you want to remove the Syncthing configuration folder, determine its location (see [Finding the Syncthing Configuration Folder](#finding-the-syncthing-configuration-folder)) and remove it after uninstalling.

## Silent Install and Uninstall

Setup supports silent (hands-free) install and uninstall mode using the `/silent` command line parameter.

* See [Setup Command Line Parameters](#setup-command-line-parameters) for information about Setup's command line parameters.

* See the [Inno Setup documentation](https://jrsoftware.org/ishelp/index.php?topic=uninstcmdline) for information about the uninstall program's conmmand line parameters.

### Silent Non Administrative (Current User) Installation

To perform an initial install (i.e., not a reinstall or upgrade) silently in non administrative (current user) installation mode, specify the `/silent` parameter on Setup's command line. (You can also include `/currentuser` on Setup's command line for clarity if desired, but this is not required as `/currentuser` is the default.) In this mode, Setup:

* Does not install the Windows service

* Does not create a firewall rule for Syncthing (this is because creating a firewall rule requires administrative permissions, which would cause a prompt that would prevent the silent installation from completing)

* Starts Syncthing for the current user if a firewall rule for Syncthing already exists

To ensure Syncthing works correctly after a non administrative (current user) silent installation, create the firewall rule manually (see [Creating the Firewall Rule Manually](#creating-the-firewall-rule-manually)) before starting Syncthing.

### Silent Administrative (All Users) Installation

To perform a silent installation in administrative installation (all users) mode, you must specify both the `/allusers` and `/silent` parameters on Setup's command line. In this mode, Setup:

* Installs the Windows service

* Automatically creates a firewall rule for Syncthing

* Starts the Syncthing service after installation completes

> NOTE: You must specify `/allusers` if reinstalling in administrative (all users) installation mode.

### Silent Uninstall

To uninstall silently, specify `/silent` on the uninstaller's command line (the uninstaller executable is located in the `uninstall` directory inside the Syncthing installation folder).

If you installed Syncthing for the current user, you must remove the Syncthing firewall rule manually (see [Removing the Firewall Rule Manually](#removing-the-firewall-rule-manually)) before uninstalling silently.

## Reporting Problems

If you encounter a problem with Setup or one of the helper tools, please inform the author by filing an issue on the Issues page:

https://github.com/Bill-Stewart/SyncthingWindowsSetup/issues

For Syncthing support (not related to Setup or the helper tools), please visit the Syncthing forum:

https://forum.syncthing.net/

## Acknowledgments

Special thanks to the following:

* Syncthing maintainers

* mtkennerly for [shawl](https://github.com/mtkennerly/shawl)

* Jordan Russell and Martijn Laan for [Inno Setup](https://www.jrsoftware.org/isinfo.php)

* [Info-ZIP](https://infozip.sourceforge.net/) maintainers

* [jq](https://jqlang.github.io/jq/) maintainers
