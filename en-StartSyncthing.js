// StartSyncthing.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Starts Syncthing for the current user in a hidden window with "below
//   normal" process priority
// * IF HKCU\Syncthing\allowautoupgrade string value in registry is 'false',
//   adds '--no-upgrade' to the command line
// * If HKCU\Syncthing\ConfigPageAddress string value in registry is set, uses
//   '--gui-address="<registryvalue>"' on the command line; if it is not set,
//   uses '--gui-address="127.0.0.1:8384"' instead
// * Use the '/silent' command line parameter to suppress dialog that appears
//   if you run this script and Syncthing is already running

// BEGIN MESSAGES
var MSG_DLG_TITLE       = "Syncthing";
var MSG_ALREADY_RUNNING = "Syncthing is already running.";
// END MESSAGES

// Global Win32 API constants
var SW_HIDE                     = 0;
var BELOW_NORMAL_PRIORITY_CLASS = 0x4000;
// Global message box constants
var MB_ICONINFORMATION = 0x40;
// Global objects
var Args         = WScript.Arguments;
var FSO          = new ActiveXObject("Scripting.FileSystemObject");
var WshShell     = new ActiveXObject("WScript.Shell");
var SWbemService = GetObject("winmgmts:{impersonationlevel=impersonate}!root/CIMV2");
// Global variables
var ScriptPath               = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);
var DefaultConfigPageAddress = "127.0.0.1:8384";

function isSyncthingRunning() {
  var path = ScriptPath.replace(/\\/g,'\\\\');
  var wqlQuery = 'SELECT Name FROM Win32_Process '
    + 'WHERE ExecutablePath LIKE "' + path + '%"';
  var procColl = new Enumerator(SWbemService.ExecQuery(wqlQuery));
  var procCount = 0;
  for ( ; ! procColl.atEnd(); procColl.moveNext() ) {
    if ( procColl.item().Name.toLowerCase() == "syncthing.exe" ) {
      procCount++;
    }
  }
  return procCount > 0;
}

function getRegistryString(path) {
  var result = "";
  try {
    result = WshShell.RegRead(path);
  }
  catch(err) {
  }
  return result;
}

function getParams() {
  var regStr = getRegistryString("HKCU\\Software\\Syncthing\\allowautoupgrade");
  var allowAutoUpgrade = regStr != "false";
  regStr = getRegistryString("HKCU\\Software\\Syncthing\\ConfigPageAddress");
  var configPageAddress = regStr == "" ? DefaultConfigPageAddress : regStr;
  var result = '--no-browser';
  if ( ! allowAutoUpgrade ) {
      result += ' --no-upgrade';
  }
  result += ' --gui-address="https://' + configPageAddress + '"';
  return result;
}

function main() {
  if ( isSyncthingRunning() ) {
    if ( ! Args.Named.Exists("silent") ) {
      WshShell.Popup(MSG_ALREADY_RUNNING,0,MSG_DLG_TITLE,MB_ICONINFORMATION);
    }
  }
  else {
    var procStartup = SWbemService.Get("Win32_ProcessStartup").SpawnInstance_();
    procStartup.ShowWindow = SW_HIDE;
    procStartup.PriorityClass = BELOW_NORMAL_PRIORITY_CLASS;
    var process = GetObject("winmgmts:{impersonationlevel=impersonate}!root/CIMV2:Win32_Process");
    var method = process.Methods_("Create");
    var inParams = method.InParameters.SpawnInstance_();
    inParams.CommandLine = '"' + FSO.BuildPath(ScriptPath,"syncthing.exe") + '" ' + getParams();
    inParams.CurrentDirectory = ScriptPath;
    inParams.ProcessStartupInformation = procStartup;
    process.ExecMethod_("Create",inParams);
  }
}

WScript.Quit(main());
