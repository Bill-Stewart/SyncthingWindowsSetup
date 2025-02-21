// SyncthingFirewallRule.js
// Written by Bill Stewart (bstewart AT iname.com) for Syncthing

// Notes:
// * Adds a Windows Firewall application rule for Syncthing
// * Removes the firewall rule
// * Tests whether the firewall rule exists; exit code = 0 if it exists, or
//   ERROR_FILE_NOT_FOUND (2) if it does not exist

// BEGIN LOCALIZATION
var MSG_DLG_TITLE            = "Syncthing";
var MSG_QUERY_CREATE_RULE    = "Create Windows Firewall rule for Syncthing?";
var MSG_QUERY_REMOVE_RULE    = "Remove Syncthing Windows Firewall rule?";
var MSG_ERROR_DESC_NOT_FOUND = "(No error description found)";
// END LOCALIZATION

// Global Windows API constants
var SW_HIDE                  = 0;
var ERROR_FILE_NOT_FOUND     = 2;
var ERROR_ELEVATION_REQUIRED = 740;
// Global message box constants
var MB_YESNO        = 0x04;
var MB_ICONERROR    = 0x10;
var MB_ICONQUESTION = 0x20;
var IDYES           = 6;
// Global FileSystemObject object constants
var ForReading      = 1;
var SystemFolder    = 1;
var TemporaryFolder = 2;
// Global objects
var Args         = WScript.Arguments;
var FSO          = new ActiveXObject("Scripting.FileSystemObject");
var WshShell     = new ActiveXObject("WScript.Shell");
var NetFWPolicy2 = new ActiveXObject("HNetCfg.FWPolicy2");
// Global variables
var ScriptPath = WScript.ScriptFullName.substring(0,WScript.ScriptFullName.length - WScript.ScriptName.length);
var RuleName   = "Syncthing";

function trim(s) {
  return s.replace(/(^\s*)|(\s*$)/g, "");
}

function getErrorDescription(errorCode) {
  // convert to unsigned if signed
  if ( errorCode < 0 ) {
    errorCode += Math.pow(2,32);
  }

  if ( errorCode.toString(0x10) == "800a0046" ) {
    errorCode = ERROR_ELEVATION_REQUIRED;
  }

  // Get temporary file name
  do
    var tempName = FSO.BuildPath(FSO.GetSpecialFolder(TemporaryFolder),
      FSO.GetTempName());
  while ( FSO.FileExists(tempName) );

  // Construct command line
  var command = FSO.BuildPath(FSO.GetSpecialFolder(SystemFolder),"cmd.exe") +
    " /c " + FSO.BuildPath(ScriptPath,"ErrInfo.exe -m -n ") +
    errorCode.toString() + " > \"" + tempName + "\"";

  // Run command (output in temporary file)
  var exitCode = WshShell.Run(command,SW_HIDE,true);
  if ( exitCode == 3871 ) {
    errorDescription = MSG_ERROR_DESC_NOT_FOUND;
  }
  else {
    try {
      var textStream = FSO.OpenTextFile(tempName,ForReading);
      var errorDescription = trim(textStream.ReadAll());
    }
    catch(err) {
      errorDescription = MSG_ERROR_DESC_NOT_FOUND;
    }
    finally {
      textStream.Close();
      FSO.DeleteFile(tempName);
    }
  }

  if ( errorCode == 0 ) {
    return errorDescription;
  }
  else {
    return "Error " + errorCode.toString() +
      " [0x" + errorCode.toString(0x10).toUpperCase() + "]: " +
      errorDescription;
  }
}

function executableRuleExists(executablePath) {
  var result = false;
  try {
    var netFWRules = new Enumerator(NetFWPolicy2.Rules);
    for ( ; ! netFWRules.atEnd(); netFWRules.moveNext() ) {
      result = netFWRules.item().ApplicationName.toLowerCase() == executablePath.toLowerCase();
      if ( result ) {
        break;
      }
    }
  }
  catch(err) {
  }
  return result;
}

function ruleExists(ruleName,executablePath) {
  var result = false;
  var netFWRule = null;
  try {
    netFWRule = NetFWPolicy2.Rules.Item(ruleName);
    if ( netFWRule != null ) {
      result = netFWRule.ApplicationName.toLowerCase() == executablePath.toLowerCase();
    }
  }
  catch(err) {
  }
  return result;
}

function createApplicationRule(ruleName,executablePath) {
  var result = 0;
  if ( ! ruleExists(ruleName,executablePath) ) {
    var netFWRule = new ActiveXObject("HNetCfg.FWRule");
    netFWRule.Name = ruleName;
    netFWRule.Action = 1;  // direction=in
    netFWRule.ApplicationName = executablePath;
    netFWRule.Enabled = true;
    netFWRule.Protocol = 256;  // no protocol restriction
    try {
      NetFWPolicy2.Rules.Add(netFWRule);
    }
    catch(err) {
      result = err.number;
    }
  }
  return result;
}

function removeRule(ruleName,executablePath) {
  var result = 0;
  if ( ruleExists(ruleName,executablePath) ) {
    try {
      NetFWPolicy2.Rules.Remove(ruleName);
    }
    catch(err) {
      result = err.number;
    }
  }
  return result;
}

function help() {
  WScript.Echo("Usage: " + WScript.ScriptName + " /create|/remove [/elevated [/silent]]\r\n"
    + "or: " + WScript.ScriptName + " /test");
}

function reportStatus(errorCode) {
  if ( errorCode != 0 ) {
    WshShell.Popup(getErrorDescription(errorCode),0,MSG_DLG_TITLE,MB_ICONERROR);
  }
}

function query(message) {
  var response = WshShell.Popup(message,0,MSG_DLG_TITLE,MB_YESNO | MB_ICONQUESTION);
  return response == IDYES;  // user clicked Yes
}

function main() {
  var result = 0;
  var syncthingPath = FSO.BuildPath(ScriptPath,"syncthing.exe");

  if ( Args.Named.Exists("elevated") ) {
    if ( Args.Named.Exists("create") ) {
      result = createApplicationRule(RuleName,syncthingPath);
    }
    else if ( Args.Named.Exists("remove") ) {
      result = removeRule(RuleName,syncthingPath);
    }
    if ( ! Args.Named.Exists("silent") ) {
      reportStatus(result);
    }
    return result;
  }
  else if ( Args.Named.Exists("test") ) {
    if ( ! executableRuleExists(syncthingPath) ) {
      result = ERROR_FILE_NOT_FOUND;
    }
    return result;
  }

  // if /elevated not specified, launch self as administrator
  var wscriptPath = FSO.BuildPath(FSO.GetSpecialFolder(SystemFolder),"wscript.exe");
  var params = '"' + WScript.ScriptFullName + '" /elevated ';
  var validParams = Args.Named.Exists("create") || Args.Named.Exists("remove");
  if ( Args.Named.Exists("create") ) {
    params += " /create";
    var prompt = MSG_QUERY_CREATE_RULE;
  }
  else if ( Args.Named.Exists("remove") ) {
    params += " /remove";
    var prompt = MSG_QUERY_REMOVE_RULE;
  }
  if ( validParams ) {
    if ( Args.Named.Exists("silent") || query(prompt) ) {
      var shellApp = new ActiveXObject("Shell.Application");
      shellApp.ShellExecute(wscriptPath,params,"","runas");
    }
  }
  else {
    help();
  }
  return result;
}

WScript.Quit(main());
