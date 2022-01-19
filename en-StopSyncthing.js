// StopSyncthing.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Stops syncthing.exe processes that were started from the same directory as
//   this script
// * Use the '/silent' command line parameter to suppress dialogs

// BEGIN LOCALIZATION
var MSG_DLG_TITLE   = "Syncthing";
var MSG_PROMPT      = "Stop Syncthing?";
var MSG_NOT_RUNNING = "Syncthing is not running.";
// END LOCALIZATION

// Global Windows API constants
var SW_HIDE            = 0;
var MB_YESNO           = 0x04;
var MB_ICONERROR       = 0x10;
var MB_ICONQUESTION    = 0x20;
var MB_ICONINFORMATION = 0x40;
var IDYES              = 6;
// Global objects
var Args         = WScript.Arguments;
var FSO          = new ActiveXObject("Scripting.FileSystemObject");
var WshShell     = new ActiveXObject("WScript.Shell");
var SWbemService = GetObject("winmgmts:{impersonationlevel=impersonate}!root/CIMV2");
// Global variables
var ScriptPath = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);

function query(message) {
  var response = WshShell.Popup(message,0,MSG_DLG_TITLE,MB_YESNO | MB_ICONQUESTION);
  return response == IDYES;  // user clicked Yes
}

function isSyncthingRunning() {
  var result = false;
  var path = ScriptPath.replace(/\\/g,'\\\\');
  var wqlQuery = 'SELECT Name,ProcessId FROM Win32_Process '
    + 'WHERE ExecutablePath LIKE "' + path + '%"';
  var procColl = new Enumerator(SWbemService.ExecQuery(wqlQuery));
  for ( ; ! procColl.atEnd(); procColl.moveNext() ) {
    var process = procColl.item();
    result = process.Name.toLowerCase() == "syncthing.exe";
    if ( result ) {
      break;
    }
  }
  return result;
}

function stopSyncthing() {
  var executablePath = FSO.BuildPath(ScriptPath,"syncthing.exe");
  return WshShell.Run('"' + executablePath + '" cli operations shutdown',SW_HIDE,true);
}

function main() {
  if ( ! isSyncthingRunning() ) {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_NOT_RUNNING,0,MSG_DLG_TITLE,MB_ICONINFORMATION);
    }
  }
  else {
    if ( Args.Named.Exists("silent") || query(MSG_PROMPT) ) {
      return stopSyncthing();
    }
  }
}

WScript.Quit(main());
