// ConfigSyncthingService.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Configures the Syncthing Windows service using NSSM (https://nssm.cc).

// BEGIN LOCALIZATION
var MSG_DLG_TITLE         = "Syncthing";
var MSG_SERVICE_NOT_EXIST = "The Syncthing service is not installed.";
// END LOCALIZATION

// Global Windows API constants
var SW_SHOWNORMAL                = 1;
var MB_ICONERROR                 = 0x10;
var ERROR_SERVICE_DOES_NOT_EXIST = 1060;
// Global objects
var Args         = WScript.Arguments;
var FSO          = new ActiveXObject("Scripting.FileSystemObject");
var WshShell     = new ActiveXObject("WScript.Shell");
var SWbemService = GetObject("winmgmts:{impersonationlevel=impersonate}!root/CIMV2");
// Global variables
var ScriptPath = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);

function getServiceName() {
  var result = "";
  var path = ScriptPath.replace(/\\/g,'\\\\');
  var quotePath = path.indexOf(" ") != -1;
  var wqlQuery = "SELECT Name FROM Win32_Service WHERE PathName='" +
    (quotePath ? '"' : '') + FSO.BuildPath(path,"nssm.exe") +
    (quotePath ? '"' : '') + "'";
  var serviceColl = new Enumerator(SWbemService.ExecQuery(wqlQuery));
  for ( ; ! serviceColl.atEnd(); serviceColl.moveNext() ) {
    result = serviceColl.item().Name;
    break;
  }
  return result;
}

function main() {
  var result = 0;
  var serviceName = getServiceName();
  if ( serviceName != "" ) {
    WshShell.Run('"' + FSO.BuildPath(ScriptPath,"nssm.exe") + '" edit "' + serviceName + '"',SW_SHOWNORMAL,false);
  }
  else {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_SERVICE_NOT_EXIST,0,MSG_DLG_TITLE,MB_ICONERROR);
    }
    result = ERROR_SERVICE_DOES_NOT_EXIST;
  }
}

WScript.Quit(main());
