import 'dart:io';

import 'shared_funcs.dart';

void chromeRestore() {
  print("Restoring Chrome data...");

  // STEP 1: Check the data exists that potentially is restored.
  if (!_chromeDataCheck()) ;

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

void chromeSnapshot() {
  print("Snapshotting Chrome data...");

  // STEP 1: Move old backup data so new data can be backed up
  if (!_moveChromeBackup()) {
    return;
  }

  // STEP 2: Backup stored data
  if (!_backupChromeSnapshot()) {
    return;
  }

  // STEP 3: Snapshot on-device data
  if (!_snapshotChromeData()) {
    return;
  }

  // STEP 4: Delete Backup.old
  _chromeRemoveBackupOld();

  print("SUCCESS: Chrome snapshot");
}

// ##############
// SNAPSHOT FUNCS
// ##############

bool _moveChromeBackup() {
  final backupDir = Directory("hrestoredata\\Chrome\\Backup");
  if (!backupDir.existsSync()) {
    return true;
  }

  final backupOperation =
      copyDirectorySync(backupDir.path, "hrestoredata\\Chrome\\Backup.old");
  if (backupOperation.$1 != 0) {
    print("\tChromeBackup operation stdout: ${backupOperation.$2}");
    print("\tChromeBackup operation ERROR stderr: ${backupOperation.$3}");
    stderr.write(
        "Failed to move the old Chrome data backup. Aborting Chrome snapshot process.");
    return false;
  }

  return true;
}

bool _backupChromeSnapshot() {
  final backupDir = Directory("hrestoredata\\Chrome\\User Data");
  if (!backupDir.existsSync()) {
    return true; // If it doesn't exist we don't need to back up but dont block.
  }

  final backupOperation =
      copyDirectorySync(backupDir.path, "hrestoredata\\Chrome\\Backup");
  if (backupOperation.$1 != 0) {
    print("\tChromeBackup operation stdout: ${backupOperation.$2}");
    print("\tChromeBackup operation ERROR stderr: ${backupOperation.$3}");
    stderr.write("Failed to backup Chrome old user data. Let's not overwrite.");
    return false;
  }

  return true;
}

bool _snapshotChromeData() {
  var uddir = Directory(
      "${Platform.environment['LOCALAPPDATA']}\\Google\\Chrome\\User Data");
  if (!uddir.existsSync()) {
    stderr.write("Chrome user data directory doesn't exist.");
    return false;
  }

  final copy = copyDirectorySync(
      "${Platform.environment['LOCALAPPDATA']}\\Google\\Chrome\\User Data",
      "hrestoredata\\Chrome\\User Data");
  if (copy.$1 != 0) {
    print("\tDirectory copy output: ${copy.$2}");
    print("\tDirectory copy ERROR output: ${copy.$3}");
    stderr.write("Failed to copy files");
    return false;
  }

  return true;
}

bool _chromeRemoveBackupOld() {
  final backupOldDir = Directory("hrestoredata\\Chrome\\Backup.old");
  if (!backupOldDir.existsSync()) {
    return true;
  }

  backupOldDir.deleteSync(recursive: true);
  return true;
}

// #############
// RESTORE FUNCS
// #############

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
