import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../shared_funcs.dart';

void driveSnapshot() {
  if (!killDriveProcess()) {
    stdout.write(" Aborting.");
    return;
  }
}

List<String>? grabAccountIDs() {
  final db = sqlite3.open(
      "${Platform.environment["LOCALAPPDATA"]}\\Google\\DriveFS\\experiments.db");

  final expDBRows = db.select("SELECT * FROM PhenotypeValues");

  int i = 0;
  for (Row row in expDBRows) {
    if (row[0] == "account_ids") {
      print(utf8.decode(row[1]).replaceAll("\n", "+").replaceFirst("+", ""));
      return (utf8.decode(row[1]).trim().split("\n"));
    }
  }

  return null;
}
