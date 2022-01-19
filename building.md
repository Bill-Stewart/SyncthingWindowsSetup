<!-- omit in toc -->
# Building Syncthing Windows Setup

- [Listing of Files](#listing-of-files)
- [Prerequisites](#prerequisites)
- [Get the Files](#get-the-files)
- [Extract the Archives](#extract-the-archives)
- [Compile the Setup Program](#compile-the-setup-program)
- [Localization](#localization)

## Listing of Files

The following table lists all of the files associated with Syncthing Windows Setup (hereafter referred to as "Setup").

| Folder or File             | Description
| --------------             | -----------
| `bin`                      | Folder contains 32-bit and 64-bit Syncthing binaries
| `nssm`                     | Folder contains 32-bit and 64-bit [NSSM](https://nssm.cc) binaries
| `redist`                   | Folder contains other files from the Syncthing download archive
| `building.md`              | This file
| `LICENSE`                  | License agreement for Setup and its associated files
| `Expand-Download.ps1`      | PowerShell script that extracts the Syncthing Windows download zip files to the correct paths for building Setup
| _lang_`-`_scriptname_`.js` | Setup installs one or more of these scripts on the user's system
| `README.md`                | Setup documentation
| `Syncthing.iss`            | Inno Setup reads this file and builds Setup
| `Localization.ini`         | Facilitates localization of the script files (see [Localization](#localization))
| `Messages-en.isl`          | Setup messages file (see [Localization](#localization))

## Prerequisites

* [7-Zip](https://www.7-zip.org/)

* [Inno Setup](https://www.jrsoftware.org/isinfo.php) version 6 or later

## Get the Files

[Download the project from Github](https://github.com/Bill-Stewart/SyncthingWindowsSetup/archive/refs/heads/main.zip) and extract it into folder of your choice (this folder will be referred to as the "build folder").

Download the Syncthing zip files for the appropriate version of Syncthing. For example, the zip files for Syncthing version 1.18.6 are `syncthing-windows-386-v1.18.6.zip` and `syncthing-windows-amd64-v1.18.6.zip`. Copy these zip files into the build folder.

## Extract the Archives

From a PowerShell command line, run the `Expand-Download.ps1` script in the build folder. The script uses 7-Zip to extract the Syncthing archive files into a folder structure appropriate for Syncthing.

## Compile the Setup Program

Use whatever method you prefer to compile `Syncthing.iss` using Inno Setup. The output filename will be `syncthing-`_version_`-setup.exe` (where _version_ is the Syncthing version).

## Localization

To add additional language support to Setup, do the following:

1. Copy the `Messages-en.isl` file to `Messages-`_lang_`.isl` (where _lang_ is the language code you want to use) and update the strings in the file.

2. Update the strings in `Messages-`_lang_`.isl` for the language.

3. Update the `[Languages]` section in the `Syncthing.iss` file.

4. Copy each `en-`_scriptname_`.js` script to _lang_`-`_scriptname_`.js` (where _lang_ is the language you want to add).

5. Edit the messages at the top of each _lang_`-`_scriptname_`.js` script such that the messages are appropriate for the language.

    > NOTE: If the messages do not display correctly when the scripts run, it may be an encoding problem. Try saving the scripts using UTF-16 LE (little endian) encoding.

6. In the `Localization.ini` file, add a section for the language, and specify the source file names you want to use for the language.

7. Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`.

8. Add a language preprocessor directive to `Syncthing.iss`, using the following syntax:

   `#define protected Languages[`_index_`] "`_lang_`"`

   (where _index_ is the next-higher index value in the `Languages` preprocessor directive array)

For example, the following steps describe how to add localization for Dutch (language code `nl`):

1. Copy `Messages-en.isl` to `Messages-nl.isl`.

2. Update the strings in `Messages-nl.isl` to Dutch.

3. Add Dutch to the `[Languages]` section in `Syncthing.iss`; e.g.:

       [Languages]
       Name: "en"; MessagesFile: "compiler:Default.isl,Messages-en.isl"
       Name: "nl"; MessagesFile: "compiler:Languages\Dutch.isl,Messaages-nl.isl"

4. Copy the `en-`_scriptname_`.js` scripts to `nl-`_scriptname_`.js` files. PowerShell example:

        Get-ChildItem en-*.js | ForEach-Object { Copy-Item $_ ($_.Name -replace '^en-','nl-') }

5. Update the messages at the top of each `nl-`_scriptname_`.js` script file to Dutch.

6. Add a section in `Localization.ini` for the Dutch language code (`nl`) and add the corresponding script file names; e.g.:

        [nl]
        ScriptNameConfigSyncthingService=nl-ConfigSyncthingService.js
        ScriptNameSetSyncthingConfig=nl-SetSyncthingConfig.js
        ScriptNameStartSyncthing=nl-StartSyncthing.js
        ScriptNameStopSyncthing=nl-StopSyncthing.js
        ScriptNameSyncthingFirewallRule=nl-SyncthingFirewallRule.js
        ScriptNameSyncthingLogonTask=nl-SyncthingLogonTask.js

7. Increment the `NumLanguages` preprocessor directive in `Syncthing.iss`; e.g.:

        #define protected NumLanguages 2

8. Also in `Syncthing.iss`, add Dutch to the `Languages` preprocessor directive array using the next higher index; e.g.:

        #define protected Languages[0] "en"
        #define protected Languages[1] "nl"
