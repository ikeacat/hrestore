import 'dart:io';

import '../shared_funcs.dart';

void driveRestore() {
  print("Restoring Drive data...");

  if (!_dataExists()) {
    stderr.write("No Drive directories found. Aborting.");
    return;
  }

  if (!killDriveProcess()) {
    stderr.write("Failed to kill the Drive process. Aborting.");
    return;
  }

  if (!_copyAccountDirectories()) {
    stderr.write("Failed to copy directories. Aborting.");
    return;
  }

  startDriveProcess(announce: true);
}

bool _dataExists() {
  if (!Directory("hrestoredata\\DriveFS").existsSync() ||
      Directory("hrestoredata\\DriveFS").listSync(followLinks: false).isEmpty) {
    return false;
  }
  return true;
}

bool _copyAccountDirectories() {
  final list = Directory("hrestoredata\\DriveFS").listSync(followLinks: false);
  if (list.isEmpty) {
    return true;
  }

  int count = 0;
  bool shouldContinue = true;
  for (FileSystemEntity entity in list) {
    if (entity.path.startsWith(".")) {
      continue;
    }

    if (FileSystemEntity.isFileSync(entity.path)) {
      continue;
    }
    if (FileSystemEntity.isDirectorySync(entity.path)) {
      final name = entity.path.split("\\").last;
      print("Copying account id $name");
      final copyOperation = copyDirectorySync(entity.path,
          "${Platform.environment["LOCALAPPDATA"]}\\Google\\DriveFS\\$name");
      if (copyOperation.$1 >= 8 && copyOperation.$1 <= 16) {
        // These are robocopy failure codes.
        stderr.write(
            "!! A FATAL ERROR has occurred copying user directories. Please examine the log. Google Drive will not be automatically started. !!\n");
        print(copyOperation);
        shouldContinue = false;
      } else {
        count++;
      }
    }
  }

  print("Restored $count account directories.");

  return shouldContinue;
}
