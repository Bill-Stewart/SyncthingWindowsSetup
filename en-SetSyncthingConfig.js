// SetSyncthingConfig.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Generate config.xml if doesn't exist
// * If generating config for service, copy generated folder
// * Set config.xml options requested by parameters
// * Disable config.xml setLowPriority option

// BEGIN LOCALIZATION
var MSG_DLG_TITLE               = "Syncthing";
var MSG_SYNCTHING_NOT_FOUND     = "syncthing.exe not found";
var MSG_CONFIG_NOT_FOUND        = "File not found:";
var MSG_CONFIG_NOT_UPDATED      = "Unable to update config.xml";
// END LOCALIZATION

// LOCAL SERVICE root profile path inside SystemRoot
var LOCALSERVICE_PROFILE_PATH = "ServiceProfiles\\LocalService";

// Global Windows API constants
var SW_HIDE              = 0;
var ERROR_FILE_NOT_FOUND = 2;
var ERROR_ALREADY_EXISTS = 183;
var MB_ICONERROR         = 0x10;
// Global Shell.Application constants
var ssfLOCALAPPDATA = 28;
var ssfWINDOWS      = 36;
// Global objects
var Args           = WScript.Arguments;
var FSO            = new ActiveXObject("Scripting.FileSystemObject");
var ShellApp       = new ActiveXObject("Shell.Application");
var WshShell       = new ActiveXObject("WScript.Shell");
var XMLDOMDocument = new ActiveXObject("Microsoft.XMLDOM");
// Global variables
var ScriptPath              = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);
var CurrentUserAppDataPath  = ShellApp.NameSpace(ssfLOCALAPPDATA).Self.Path;
var LocalizedAppDataPath    = FSO.BuildPath(FSO.GetFileName(FSO.GetParentFolderName(CurrentUserAppDataPath)),FSO.GetFileName(CurrentUserAppDataPath));
var LocalServiceAppDataPath = FSO.BuildPath(FSO.BuildPath(ShellApp.NameSpace(ssfWINDOWS).Self.Path,LOCALSERVICE_PROFILE_PATH),LocalizedAppDataPath);

function help() {
  WScript.Echo("Usage: " + WScript.ScriptName + " {/currentuser|/localservice} <settings> [/silent]");
}

function paramIsEmpty(paramName) {
  return (Args.Named.Item(paramName) == "") || (Args.Named.Item(paramName) == null);
}

function copyFolder(source,destination) {
  result = 0;
  if ( destination.charAt(destination.length - 1) != "\\" ) {
    destination += "\\";
  }
  try {
    FSO.CopyFolder(source,destination,false);
  }
  catch(err) {
    result = err.number;
  }
  return result;
}

function main() {
  var currentUserConfigDir = FSO.BuildPath(CurrentUserAppDataPath,"Syncthing");
  var currentUserConfigFileName = FSO.BuildPath(currentUserConfigDir,"config.xml");
  var localServiceConfigDir = FSO.BuildPath(LocalServiceAppDataPath,"Syncthing");
  var localServiceConfigFileName = FSO.BuildPath(localServiceConfigDir,"config.xml");

  // Following depend on /currentuser or /localservice parameter
  var configFileName = null;         // Path/filename of config.xml
  var copyCurrentUserConfig = null;  // Copy current user config to service?
  var defaultFolder = null;          // Add default folder to config?
  var generate = null;               // Need to generate config.xml?

  if ( Args.Named.Exists("currentuser") ) {
    configFileName = currentUserConfigFileName;
    copyCurrentUserConfig = false;
    defaultFolder = true;
    generate = ! FSO.FileExists(currentUserConfigFileName);
  }
  else if ( Args.Named.Exists("localservice") ) {
    configFileName = localServiceConfigFileName;
    copyCurrentUserConfig = true;
    defaultFolder = false;
    generate = ! FSO.FileExists(localServiceConfigFileName);
  }
  else {
    help();
    return;
  }

  if ( generate ) {
    var syncthingPath = FSO.BuildPath(ScriptPath,"syncthing.exe");
    if ( ! FSO.FileExists(syncthingPath) ) {
      if ( ! Args.Named.Exists("silent") ) {
        WshShell.Popup(MSG_SYNCTHING_NOT_FOUND,0,MSG_DLG_TITLE,MB_ICONERROR);
      }
      return ERROR_FILE_NOT_FOUND;
    }
    var cmdLine = '"' + syncthingPath + '" generate --skip-port-probing';
    if ( ! defaultFolder ) {
      cmdLine += ' --no-default-folder';
    }
    // Generate configuration (current user)
    WshShell.Run(cmdLine,SW_HIDE,true);
    if ( ! FSO.FileExists(currentUserConfigFileName) ) {
      if ( ! Args.Named.Exists("silent") ) {
        WshShell.Popup(MSG_CONFIG_NOT_FOUND + "\n\n" + currentUserConfigFileName,0,MSG_DLG_TITLE,MB_ICONERROR);
      }
      return ERROR_FILE_NOT_FOUND;
    }
    // Copy current user configuration to LOCAL SERVICE config
    if ( copyCurrentUserConfig ) {
      copyFolder(currentUserConfigDir,FSO.GetParentFolderName(localServiceConfigDir));
    }
  }

  if ( ! FSO.FileExists(configFileName) ) {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_CONFIG_NOT_FOUND + "\n\n" + configFileName,0,MSG_DLG_TITLE,MB_ICONERROR);
    }
    return ERROR_FILE_NOT_FOUND;
  }

  // Set configuration options
  var xmlElement = null;
  var configValue = null;
  try {
    XMLDOMDocument.load(configFileName);
    // Configure GUI address
    if ( Args.Named.Exists("guiaddress") ) {
      xmlElement = XMLDOMDocument.selectSingleNode("//configuration/gui/address");
      configValue = Args.Named.Item("guiaddress");
      if ( xmlElement.text != configValue ) {
        xmlElement.text = paramIsEmpty("guiaddress") ? "127.0.0.1:8384" : configValue;
        XMLDOMDocument.save(configFileName);
      }
    }
    // Configure autoUpgradeIntervalH
    if ( Args.Named.Exists("autoupgradeinterval") ) {
      xmlElement = XMLDOMDocument.selectSingleNode("//configuration/options/autoUpgradeIntervalH");
      configValue = Args.Named.Item("autoupgradeinterval");
      xmlElement.text = paramIsEmpty("autoupgradeinterval") ? "12" : configValue;
      XMLDOMDocument.save(configFileName);
    }
    // Configure setLowPriority
    xmlElement = XMLDOMDocument.selectSingleNode("//configuration/options/setLowPriority");
    if ( xmlElement.text.toLowerCase() != "false" ) {
      xmlElement.text = "false";
      XMLDOMDocument.save(configFileName);
    }
  }
  catch(err) {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_CONFIG_NOT_UPDATED,0,MSG_DLG_TITLE,MB_ICONERROR);
    }
    return err.number;
  }
}

WScript.Quit(main());
