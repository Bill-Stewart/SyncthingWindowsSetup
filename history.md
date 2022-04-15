# Syncthing Windows Setup Version History

Below are the release notes for Syncthing Windows Setup (herein after referred to as Setup).

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
