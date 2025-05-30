<!-- omit in toc -->
# Building Syncthing Windows Setup

- [Listing of Files](#listing-of-files)
- [Get the Files](#get-the-files)
- [Build Setup](#build-setup)
- [Localization Steps](#localization-steps)
- [Localization Example](#localization-example)

## Listing of Files

The following table lists all of the files associated with Syncthing Windows Setup (hereafter referred to as "Setup").

| Folder or File             | Description
| --------------             | -----------
| `binaries`                 | Folder contains 32-bit (i386) and 64-bit (x86_64) binaries
| `building.md`              | This file
| _lang_`-License.rtf`       | License information shown on the **License** page of the installer wizard
| _lang_`-README.rtf`        | README information shown on the **Information** page of the installer wizard
| _lang_`-`_scriptname_`.js` | Setup installs one or more of these WSH scripts on the user's system
| `jq.exe`                   | 32-bit [jq](https://jqlang.github.io/jq/) tool (used during installation only)
| `LICENSE`                  | License agreement
| `Localization.ini`         | Facilitates localization of the script files (see [Localization](#localization))
| `Messages-`_lang_`.isl`    | Setup messages file (see [Localization](#localization))
| `ProcessCheck.dll`         | 32-bit [ProcessCheck](https://github.com/Bill-Stewart/ProcessCheck) DLL (used during installation only)
| `README.md`                | Setup documentation
| `SetupVersion.ini`         | Setup version file
| `Syncthing.iss`            | Inno Setup source script
| `UninsIS.dll`              | 32-bit [UninsIS](https://github.com/Bill-Stewart/UninsIS) DLL (used during installation only)
| `unzip.exe`                | 32-bit [UnZip](https://infozip.sourceforge.net/) tool (used during installation only)

## Get the Files

1. [Download the project from Github](https://github.com/Bill-Stewart/SyncthingWindowsSetup/archive/refs/heads/main.zip) and extract it into a folder of your choice.

2. Download the executables for the `binaries` folder:

   * [asmt](https://github.com/Bill-Stewart/asmt/releases/latest/)
   * [ErrInfo](https://github.com/Bill-Stewart/ErrInfo)
   * [ServMan](https://github.com/Bill-Stewart/ServMan/releases/latest/)
   * [shawl](https://github.com/mtkennerly/shawl/releases/latest/)
   * [stctl](https://github.com/Bill-Stewart/stctl/releases/latest/)

3. Put the 32-bit binaries in the `binaries\i386` folder and the 64-bit binaries in the `binaries\x86_64` folder.

## Build Setup

Use whatever method you prefer to compile `Syncthing.iss` using Inno Setup. The output filename will be `syncthing-windows-setup.exe`.

## Localization Steps

To add additional language support to Setup, do the following:

1.  Copy the `Messages-en.isl` file to `Messages-`_lang_`.isl` (where _lang_ is the language code you want to use) and update the strings in the file.

2.  Update the strings in `Messages-`_lang_`.isl` for the language.

3.  Provide a translated copy of the license in Rich Text Format (RTF) as _lang_`-License.rtf`.

4.  Provide a translated copy of the "README" file in RTF as _lang_`-README.rtf`.

5.  Update the `[Languages]` section in the `Syncthing.iss` file.

6.  Copy each `en-`_scriptname_`.js` script to _lang_`-`_scriptname_`.js` (where _lang_ is the language you want to add).

7.  Edit the messages at the top of each _lang_`-`_scriptname_`.js` script such that the messages are appropriate for the language.

    > NOTE: If the messages do not display correctly when the scripts run, it may be an encoding problem. Try saving the scripts using UTF-16 LE (little endian) encoding.

8.  In the `Localization.ini` file, add a section for the language, and specify the source file names you want to use for the language.

9.  Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`.

10. Add a language preprocessor directive to `Syncthing.iss`, using the following syntax:

     `#define Languages[`_index_`] "`_lang_`"`

     (where _index_ is the next-higher index value in the `Languages` preprocessor directive array)

## Localization Example

The following steps describe how to add localization for Dutch (language code `nl`):

1.  Copy `Messages-en.isl` to `Messages-nl.isl`.

2.  Update the strings in `Messages-nl.isl` to Dutch.

3.  Provide a Dutch-language copy of the license in Rich Text Format (RTF) as `nl-License.rtf`.

4.  Provide a Dutch-language copy of the README in RTF as `nl-README.rtf`.

5.  Add Dutch to the `[Languages]` section in `Syncthing.iss`; e.g.:

        [Languages]
        Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"; InfoBeforeFile: "en-README.rtf"
        Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl,Messages-nl.isl"; InfoBeforeFile: "nl-README.rtf"

6.  Copy the `en-`_scriptname_`.js` scripts to `nl-`_scriptname_`.js` files. PowerShell example:

        Get-ChildItem en-*.js | ForEach-Object { Copy-Item $_ ($_.Name -replace '^en-','nl-') }

7.  Update the messages at the top of each `nl-`_scriptname_`.js` script file to Dutch.

8.  Add a section in `Localization.ini` for the Dutch language code (`nl`) and add the corresponding file names; e.g.:

        [nl]
        LicenseFile=nl-License.rtf
        ScriptNameSetSyncthingConfig=nl-SetSyncthingConfig.js
        ScriptNameSyncthingFirewallRule=nl-SyncthingFirewallRule.js
        ScriptNameSyncthingLogonTask=nl-SyncthingLogonTask.js

9.  Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`; e.g.:

        ...
        #define NumLanguages 2
        ...

10. Also in `Syncthing.iss`, add Dutch to the `Languages` preprocessor directive array using the next higher index; e.g.:

        ...
        #define Languages[0] "en"
        #define Languages[1] "nl"
        ...
