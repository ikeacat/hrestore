import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

(int, dynamic, dynamic) copyDirectorySync(String from, String to) {
  final moveProc = Process.runSync("robocopy", [from, to], runInShell: false);
  return (moveProc.exitCode, moveProc.stdout, moveProc.stderr);
}

bool killDriveProcess() {
  var taskkill = Process.runSync(
      "taskkill", ["/im", "GoogleDriveFS.exe", "/f", "/t"],
      runInShell: true);
  if (taskkill.exitCode != 0 && taskkill.exitCode != 128) {
    // 128: proc not found
    print("\tTaskkill code: ${taskkill.exitCode}");
    print("\tTaskkill output: ${taskkill.stdout}");
    print("\tTaskkill ERROR output: ${taskkill.stderr}");
    stderr.write("Not sure if Google Drive was killed (non-zero exit code).");
    return false;
  }
  return true;
}

void setupSqliteLibrary() {
  open.overrideFor(OperatingSystem.windows, () {
    return DynamicLibrary.open("lib/sqlite3.dll");
  });
}
