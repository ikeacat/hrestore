import 'dart:io';

void driveRestore() {
  print("Restoring Drive data...");

  if (!_dataExists()) {
    stderr.write("No Drive directories found. Aborting.");
  }
}

bool _dataExists() {
  if (!Directory("hrestoredata/DriveFS").existsSync() ||
      Directory("hrestore/DriveFS").listSync(followLinks: false).isEmpty) {
    return false;
  }
  return true;
}
