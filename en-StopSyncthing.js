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

// Global message box constants
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

// Gets array of process IDs of processes running from this script's directory
function getProcessIDs() {
  var path = ScriptPath.replace(/\\/g,'\\\\');
  var wqlQuery = 'SELECT Name,ProcessId FROM Win32_Process '
    + 'WHERE ExecutablePath LIKE "' + path + '%"';
  var procColl = new Enumerator(SWbemService.ExecQuery(wqlQuery));
  var processIDs = [];
  for ( ; ! procColl.atEnd(); procColl.moveNext() ) {
    var process = procColl.item();
    if ( process.Name.toLowerCase() == "syncthing.exe" ) {
      processIDs.push(process.processId);
    }
  }
  return processIDs;
}

// Terminates process IDs passed in processIDs array
function terminateProcesses(processIDs) {
  var wqlQuery = 'SELECT Name FROM Win32_Process WHERE ((ProcessId='
    + processIDs[0].toString() + ')';
  for ( var i = 1; i < processIDs.length; i++ ) {
    wqlQuery += ' OR (ProcessId=' + processIDs[i].toString() + ')';
  }
  wqlQuery += ')';
  var procColl = new Enumerator(SWbemService.ExecQuery(wqlQuery));
  for ( ; ! procColl.atEnd(); procColl.moveNext() ) {
    try {
      procColl.item().Terminate();
    }
    catch(err) {
    }
  }
}

function main() {
  var processIDs = getProcessIDs();
  if ( processIDs.length == 0 ) {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_NOT_RUNNING,0,MSG_DLG_TITLE,MB_ICONINFORMATION);
    }
  }
  else {
    if ( Args.Named.Exists("silent") || query(MSG_PROMPT) ) {
      terminateProcesses(processIDs);
    }
  }
}

WScript.Quit(main());
