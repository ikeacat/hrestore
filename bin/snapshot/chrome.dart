import 'dart:io';

import '../shared_funcs.dart';

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
