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

  if (!startDriveProcess()) {
    stderr
        .write("Failed to start the Drive process. Please start it manually.");
  }
}

bool _dataExists() {
  if (!Directory("hrestoredata/DriveFS").existsSync() ||
      Directory("hrestore/DriveFS").listSync(followLinks: false).isEmpty) {
    return false;
  }
  return true;
}
