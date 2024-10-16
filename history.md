# Syncthing Windows Setup Version History

Below are the release notes for Syncthing Windows Setup (herein after referred to as Setup).

## 1.27.28 (2024-10-16)

* Fixed: zip file extraction now (correctly) overwrites destination files.

## 1.27.12 (2024-10-04)

* Moved Setup's version number from the main wizard window title to the version number of the executable.

* Setup now checks for a valid `HKEY_CLASSES_ROOT\.js` WSH script registration and aborts if the value is not correct.

* Added section in documentation regarding initialization errors.

## 1.27.11 (2024-09-03)

* Setup now automatically downloads and installs the latest version of Syncthing from GitHub.

* Setup now also supports offline installation mode where you can specify the Syncthing download zip file.

* Setup's executable size now is much smaller due to the above.

* Added `desktopicon` task (not selected by default).

* Added informational wizard page and moved license to a separate wizard page.

* Corrected some errors in the documentation.

* Built Setup using Inno Setup 6.3.3.

## 1.27.9 (2024-07-03)

* Security enhancement: Prevent service installation on a domain controller.

* Upgrade to Inno Setup 6.3.2.

* Enhancement: Install x64 binaries on AMD64 if OS supports it.

## 1.27.6 (2024-04-12)

* Fix: `startatlogon` task now appears when reinstalling and upgrading.

* Added `startatlogon\acpoweronly` task. This task is disabled by default.

## 1.27.5 (2024-04-02)

* Updated [shawl](https://github.com/mtkennerly/shawl) utility to v1.5.0.

## 1.27.3 (2024-02-06)

* PowerShell scripts and `startps.exe` have been replaced with **[asmt](https://github.com/Bill-Stewart/asmt)**. Hopefully this will reduce anti-malware software false positives.

* Start and stop scripts for per-user installations have been replaced with **[stctl](https://github.com/Bill-Stewart/stctl)**. Hopefully this will reduce anti-malware software false positives.

* Setup now uses [ProcessCheck.dll](https://github.com/Bill-Stewart/ProcessCheck) to find running processes rather than a WMI query. Hopefully this will reduce anti-malware software false positives.

* Minor tweaks.

## 1.27.2 (2024-01-02)

* Syncthing 1.27.1 and later is built using Go >= version 1.21.5, which no longer supports Windows versions older than Windows 10/Server 2016. Accordingly, Setup requires at least Windows 10/Server 2016 or later to install Syncthing. (See https://github.com/golang/go/issues/64622 and https://forum.syncthing.net/t/21248 for further information.)

* Minor tweaks.

## 1.27.1 (2023-12-11)

* Added: Prevent accidental downgrades by canceling installation if installing version is lower than installed version.

## 1.27.0 (2023-12-07)

* Fixed: Service reinstall did not reset the service account password under some circumstances.

* Updated check for Syncthing running state to wait for up to 10 seconds at post-install.

* Updated [shawl](https://github.com/mtkennerly/shawl) utility.

* Changed service start/stop to the [ServMan](https://github.com/Bill-Stewart/ServMan) utility.

* Changed:

  * Upgrading from a version older than 1.27.0 performs an automatic uninstall first. This change was made to clean up legacy upgrade code. Due to this change, if you upgrade an administrative install from version 1.19.1 the configuration will not be migrated. You must first upgrade to version 1.26.1 to migrate the configuration, and then upgrade to 1.27.0 or later.

  * Added `/noconfigpage` parameter to hide checkbox on post-install page.

  * Added `SetupVersion.ini` to manage Setup version for later upgrades.

* Automatic uninstall provided by [UninsIS.dll](https://github.com/Bill-Stewart/UninsIS/).

## 1.26.0 (2023-11-06)

* Fixed: Configuration file path permission not set correctly for admin installs when service account doesn't yet exist.

* Changed:

  * Removed Setup `/nostart` command line parameter. Use the `startserviceafterinstall` (admin install mode) or `startafterinstall` (non admin install mode) tasks instead.

  * Updated post-install page to allow user to open the Syncthing configuration page.

## 1.25.0 (2023-10-03)

* Due to a number of security vendors automatically assuming NSSM is malware (even though it was being used legitimately), Setup now uses [shawl](https://github.com/mtkennerly/shawl) to run the Windows service. (The hope is that this will reduce the number of security software false positive malware notitifications when downloading and running Setup.)

* At the request of the Syncthing maintainers, relaying is now enabled by default. If you installed an older version that disabled relays by default and you want to enable relaying, do one of the following:

  * On the **Select Configuration Settings** page, specify `true` for the **Relays enabled** option, or
  * Specify `/relaysenabled=true` on the Setup command line

* Removed **Configure Syncthing Service** shortcut (administrative installation mode only).

* Added `Reset-SyncthingServiceAccountPassword.ps1` script (administrative installation mode only).

* The name of the installed package in the Windows application list now reflects the installation mode (**admin** or **current user**).

## 1.23.7 (2023-08-10)

* For new installs, Setup now defaults to non-administrative installation mode.

* Added `relaysenabled` configuration item that defaults to `false`.

## 1.22.2 (2022-12-08)

* Installer now installs the ARM64 version of `syncthing.exe` on that platform.

* Removed **FAQ** and **Getting Started** PDF shortcuts (Syncthing team is now longer including these in the downloads).

* Mozilla Public License (MPL) shows in installer as informational only rather than as a license agreement that requires acceptance to install.

## 1.22.1 (2022-12-03)

* Added license page to installer.

* Uninstall now deletes `syncthing.exe.old` when uninstalling.

## 1.21.0 (2022-09-10)

* In 1.20.1 and older, Syncthing automatic upgrades might not work for new installations until after a reinstall. (This was because the installer was resetting the permissions of the installation folder before creating the service account.) This is now fixed.

## 1.20.1 (2022-05-11)

* Setup built using Inno Setup 6.2.1.

## 1.19.2 (2022-04-14)

* For improved security, administrative installation mode now configures the service to run using a local user account (by default, **SyncthingServiceAcct**) rather than the **LocalService** account. As a part of this change, the Syncthing configuration data is now located in the _CommonAppData_`\Syncthing` folder (e.g., `C:\ProgramData\Syncthing`).

* When upgrading an administrative installation from 1.19.1 or older, Setup automatically migrates the Syncthing configuration data from the legacy **LocalService** account user profile (e.g., `C:\Windows\ServiceProfiles\LocalService\ApplicationData\Local\Syncthing`) to the updated configuration data folder (e.g., `C:\ProgramData\Syncthing`). If the migration succeeds, Setup offers to remove the legacy configuration folder. (A silent installation will automatically remove the legacy configuration folder if the migration succeeded.)

  > NOTE: If you upgrade an administrative installation of 1.19.1 or older, please see `README.md` for instructions on how to grant the service's local user account "Modify" permissions to folder(s) in the Syncthing configuration.

* The `startatboot` task (i.e., **the Start Syncthing service automatically when system boots** checkbox on the **Select Additional Tasks** page) in administrative installation mode configures the Windows service accordingly when reinstalling or upgrading.

## 1.19.1 (2022-03-16)

* No Setup changes.

## 1.19.0 (2022-02-02)

* `SetSyncthingConfig.js` no longer requires firewall rule (thanks to Syncthing maintainers for adding `--skip-port-probing` option).

## 1.18.6.5 (2022-01-19)

* Fix: No error dialog from `SetSyncthingConfig.js` script if running silently.

* Fix: If GUI listen address specified as "any" (`0.0.0.0` or `::`), then set `ConfigurationPage.url` to use `127.0.0.1`.

* Minor tweaks.

## 1.18.6.4 (2022-01-14)

* Fixed wrong `SetSyncthingConfig.js` included in build.

## 1.18.6.3 (2022-01-13)

* Fix: Setup now looks up localized account name for `NT AUTHORITY\LOCAL SERVICE` when installing service.

## 1.18.6.2 (2022-01-12)

* Fix: Configuration wasn't being generated correctly for Windows service.

* Fix: Don't show `startatboot` task if service is already installed.

* Improved: `StopSyncthing.js` uses CLI command (`syncthing cli operations shutdown`) to stop Syncthing.

## 1.18.6 (2022-01-11)

> NOTE: If you installed Syncthing 1.18.5 using Setup, it is recommended to uninstall it first before installing 1.18.6 or any newer version. This is recommended due to the improved way that Setup handles configuration settings in 1.18.6 and newer.

* Setup now remembers configuration page data between runs.

* Improved firewall rule detection.

* Removed `allowautoupgrade` task and replaced it with the  `/autoupgradeinterval` parameter (specifies number of hours between automatic upgrade checks). This value is also settable during interactive install on the configuration wizard page.

* Added `InitSyncthingConfig.js` script for updating `config.xml`:

  * Configures automatic upgrade interval (in hours)

  * Configures GUI configuration page address and port

  * Configures `setLowPriority` setting to `false`

  Setup runs this script when installing so that the user's preferences get written to `config.xml`.

* Non administrative (current user) installation no longer writes Syncthing configuration data to the registry.

## 1.18.5 (2021-12-28)

* Initial version.
