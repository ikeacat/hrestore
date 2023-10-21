import '../shared_funcs.dart';

import 'dart:io';

void chromeRestore() {
  print("Restoring Chrome data...");

  // STEP 1: Check the data exists that potentially is restored.
  if (!_chromeDataCheck()) {
    return;
  }

  // STEP 2: Kill Chrome
  if (!_killChrome()) {
    return;
  }

  // STEP 3: Delete old user data
  if (!_deleteChromeData()) {
    return;
  }

  // STEP 4: Restore the old user data
  if (!_restoreChromeData()) {
    return;
  }

  print("SUCCESS: Chrome restore");
}

bool _chromeDataCheck() {
  print("\tChecking Chrome user data exists to restore...");
  if (!Directory("hrestoredata\\Chrome\\User Data").existsSync()) {
    stderr.write(
        "No directory exists to restore Chrome data from. Aborting Chrome snapshot.");
    return false;
  }
  return true;
}

bool _killChrome() {
  print("\tKilling the Chrome process...");

  var taskkill = Process.runSync("taskkill", ["/im", "Chrome.exe", "/f", "/t"],
      runInShell: true);
  if (taskkill.exitCode != 0 && taskkill.exitCode != 128) {
    // 128: proc not found
    print("\tTaskkill code: ${taskkill.exitCode}");
    print("\tTaskkill output: ${taskkill.stdout}");
    print("\tTaskkill ERROR output: ${taskkill.stderr}");
    stderr.write(
        "Not sure if Chrome was killed (non-zero exit code), aborting Chrome restore process.");
    return false;
  }
  return true;
}

bool _deleteChromeData() {
  print("\tDeleting old Chrome user data...");
  if (!Platform.environment.containsKey("LOCALAPPDATA")) {
    stderr.write(
        "Environment variables dont point to any local AppData directories. Is this Windows? Aborting Chrome restore.");
    return false;
  }

  var uddir = Directory(
      "${Platform.environment['LOCALAPPDATA']}\\Google\\Chrome\\User Data");
  if (uddir.existsSync()) {
    bool sw = true;
    while (true) {
      try {
        uddir.deleteSync(recursive: true);
      } on PathAccessException {
        if (sw) {
          print(
              "\t\tChrome is still holding onto user data, awaiting Chrome to stop...");
          sw = false;
        }
        continue;
      }
      if (!sw) {
        print("\t\tFinally.");
      }
      break;
    }
  }
  return true;
}

bool _restoreChromeData() {
  print("\tRestoring user data...");

  final data = Directory("hrestoredata\\Chrome\\User Data");
  if (!data.existsSync()) {
    stderr.write(
        "Failed to find the user data. (Not at hrestoredata > Chrome > User Data). Aborting Chrome restore.");
    return false;
  }

  final moveProc = copyDirectorySync("hrestoredata\\Chrome\\User Data",
      "${Platform.environment['LOCALAPPDATA']}\\Google\\Chrome\\User Data");
  if (moveProc.$1 != 0) {
    print("\tDirectory copy output: ${moveProc.$2}");
    print("\tDirectory copy ERROR output: ${moveProc.$3}");
    stderr.write("Failed to copy files");
    return false;
  }
  return true;
}
