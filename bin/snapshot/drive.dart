import 'dart:convert';
import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../shared_funcs.dart';

void driveSnapshot() {
  if (!killDriveProcess()) {
    stdout.write(" Aborting.");
    return;
  }

  if (!_copyAccountDirectories()) {
    stderr.write(" Aborting.");
    return;
  }

  print("SUCCESS: Drive snapshot");
}

bool _copyAccountDirectories() {
  final ids = grabAccountIDs() ?? [];
  if (ids.isEmpty) {
    return false;
  }

  int count = 0;
  for (String id in ids) {
    if (id.trim().isEmpty) {
      continue;
    }

    id = id.trim();

    var proc = copyDirectorySync(
        "${Platform.environment["LOCALAPPDATA"]}\\Google\\DriveFS\\$id",
        "hrestoredata/DriveFS/$id");
    if (proc.$1 == 0) {
      count++;
    }
  }

  print("Copied $count user director(y)(ies)");

  if (count > 0) {
    return true;
  }
  return false;
}

List<String>? grabAccountIDs() {
  final db = sqlite3.open(
      "${Platform.environment["LOCALAPPDATA"]}\\Google\\DriveFS\\experiments.db");

  final expDBRows = db.select("SELECT * FROM PhenotypeValues");
  for (Row row in expDBRows) {
    if (row[0] == "account_ids") {
      return utf8.decode(row[1], allowMalformed: false).split("\u0015");
    }
  }

  return null;
}
