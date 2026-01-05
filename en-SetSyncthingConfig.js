// SetSyncthingConfig.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Generate config.xml if doesn't exist
// * Set config.xml options requested by parameters
// * Disable config.xml setLowPriority option

// BEGIN LOCALIZATION
var MSG_DLG_TITLE           = "Syncthing";
var MSG_SYNCTHING_NOT_FOUND = "syncthing.exe not found";
var MSG_SYNCTHING_ERROR     = "syncthing.exe returned an error";
var MSG_CONFIG_NOT_FOUND    = "File not found:";
var MSG_CONFIG_NOT_UPDATED  = "Unable to update config.xml";
// END LOCALIZATION

// Global Windows API constants
var SW_HIDE              = 0;
var ERROR_FILE_NOT_FOUND = 2;
var ERROR_ALREADY_EXISTS = 183;
var MB_ICONERROR         = 0x10;
// Global Shell.Application constants
var ssfLOCALAPPDATA  = 0x1C;
var ssfCOMMONAPPDATA = 0x23;
// Global objects
var Args           = WScript.Arguments;
var FSO            = new ActiveXObject("Scripting.FileSystemObject");
var ShellApp       = new ActiveXObject("Shell.Application");
var WshShell       = new ActiveXObject("WScript.Shell");
var XMLDOMDocument = new ActiveXObject("Microsoft.XMLDOM");
// Global variables
var ScriptPath = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);

// Version object for comparing version number strings 'a[.b[.c[.d]]]'
// compare() method returns:
// * -1 if object's version < otherVersion
// * 0 if object's version == otherVersion
// * > 1 if object's version > otherVersion
function Version(value) {
  var isValid = true;
  this.parts = value.split(".");
  if ( this.parts.length != 4 )
    this.parts.length = 4;
  for ( var i = 0; i < this.parts.length; i++ ) {
    if ( (this.parts[i] == null) || (this.parts[i] == "") ) {
      var part = 0;
    }
    else {
      part = parseInt(this.parts[i],10);
      isValid = (! isNaN(part)) && (part <= 0xFFFF);
    }
    if ( ! isValid ) {
      this.parts = [0,0,0,0];
      break;
    }
    this.parts[i] = part;
  }
  this.compare = function(otherVersion) {
    var result = -1;
    for ( var i = 0; i < 4; i++ ) {
      if ( this.parts[0] > otherVersion.parts[0] ) {
        result = 1;
      }
      else if ( this.parts[0] == otherVersion.parts[0] ) {
        if ( this.parts[1] > otherVersion.parts[1] ) {
          result = 1;
        }
        else if ( this.parts[1] == otherVersion.parts[1] ) {
          if ( this.parts[2] > otherVersion.parts[2] ) {
            result = 1;
          }
          else if ( this.parts[2] == otherVersion.parts[2] ) {
            if ( this.parts[3] > otherVersion.parts[3] ) {
              result = 1;
            }
            else if ( this.parts[3] == otherVersion.parts[3] ) {
              result = 0;
            }
          }
        }
      }
    }
    return result;
  }
}

function help() {
  WScript.Echo("Usage: " + WScript.ScriptName + " {/currentuser|/service} <settings> [/silent]");
}

function paramIsEmpty(paramName) {
  return (Args.Named.Item(paramName) == "") || (Args.Named.Item(paramName) == null);
}

function getBoolStringParam(paramName) {
  if ( paramIsEmpty(paramName) ) {
    return "false";
  }
  return Args.Named.Item(paramName).toLowerCase() == "true" ? "true" : "false";
}

function main() {
  // Following depend on /currentuser or /service parameter
  var configPath = null;      // Syncthing config file path
  var defaultFolder = null;   // Add default folder to config?
  var configFileName = null;  // Path/filename of config.xml
  var generate = null;        // Need to generate config.xml?

  if ( Args.Named.Exists("currentuser") ) {
    var currentUserLocalAppDataPath = ShellApp.NameSpace(ssfLOCALAPPDATA).Self.Path;
    configPath = FSO.BuildPath(currentUserLocalAppDataPath,"Syncthing");
    defaultFolder = true;
  }
  else if ( Args.Named.Exists("service") ) {
    var commonAppDataPath = ShellApp.nameSpace(ssfCOMMONAPPDATA).Self.Path;
    configPath = FSO.BuildPath(commonAppDataPath,"Syncthing");
    defaultFolder = false;
  }
  else {
    help();
    return;
  }

  configFileName = FSO.BuildPath(configPath,"config.xml");
  generate = ! FSO.FileExists(configFileName);

  if ( generate ) {
    var syncthingPath = FSO.BuildPath(ScriptPath,"syncthing.exe");
    if ( ! FSO.FileExists(syncthingPath) ) {
      if ( ! Args.Named.Exists("silent") ) {
        WshShell.Popup(MSG_SYNCTHING_NOT_FOUND,0,MSG_DLG_TITLE,MB_ICONERROR);
      }
      return ERROR_FILE_NOT_FOUND;
    }
    var version = new Version(FSO.GetFileVersion(syncthingPath));
    var isLegacy = version.compare(new Version("2")) < 0;
    // version >= 2 uses --no-port-probing rather than --skip-port-probing
    portParam = ! isLegacy ? '--no-port-probing' : '--skip-port-probing';
    var cmdLine = '"' + syncthingPath + '" generate ' + portParam + ' --home="' + configPath + '"';
    // version >= 2 does not support --no-default-folder
    if ( isLegacy && (! defaultFolder) ) {
      cmdLine += ' --no-default-folder';
    }
    // Generate configuration; fail if non-zero exit code
    var exitCode = WshShell.Run(cmdLine,SW_HIDE,true);
    if ( exitCode != 0 ) {
      if ( ! Args.Named.Exists("silent") ) {
        WshShell.Popup(MSG_SYNCTHING_ERROR,0,MSG_DLG_TITLE,MB_ICONERROR);
      }
      return exitCode;
    }
    // Fail if not found
    if ( ! FSO.FileExists(configFileName) ) {
      if ( ! Args.Named.Exists("silent") ) {
        WshShell.Popup(MSG_CONFIG_NOT_FOUND + "\n\n" + configFileName,0,MSG_DLG_TITLE,MB_ICONERROR);
      }
      return ERROR_FILE_NOT_FOUND;
    }
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
    // Configure relaysEnabled
    if ( Args.Named.Exists("relaysenabled") ) {
      xmlElement = XMLDOMDocument.selectSingleNode("//configuration/options/relaysEnabled");
      configValue = getBoolStringParam("relaysenabled");
      if ( xmlElement.text != configValue ) {
        xmlElement.text = configValue;
        XMLDOMDocument.save(configFileName);
      }
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
