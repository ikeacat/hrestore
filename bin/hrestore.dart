import 'dart:io';

import 'config_store.dart';
import 'restore/restore.dart';
import 'snapshot/snapshot.dart';
import 'shared_funcs.dart';

void main(List<String> arguments) async {
  print("HRestore v1.0.0 \"Initial Release\" (TBD)");
  print("Made with love\n");

  if (!Platform.isWindows) {
    print("HRestore is only supported on Windows, sorry!");
    exit(1);
  }

  print("Checking for required files...");
  if (!File("lib/sqlite3.dll").existsSync()) {
    stderr.write("Failed to find lib/sqlite3.dll. Aborting.");
    exit(2);
  }

  setupSqliteLibrary();

  print("Searching for and loading a configuration...");
  if (!File("hrestore.cfg").existsSync()) {
    stderr.write(
        "Failed to find a config file (hrestore.cfg) in the current directory.");
    exit(2);
  }

  final loader = ConfigStore(origin: "hrestore.cfg");
  await loader.load();
  loader.commit();

  // Check for restore or snapshot.
  var mode = loader.getValue("Mode");
  if (mode == null) {
    stderr.write("Check your config, it should have a mode.");
    exit(2);
  }

  if (mode == "restore") {
    print("\nMode: RESTORE");
    restore();
  } else if (mode == "snapshot") {
    print("\nMode: SNAPSHOT");
    snapshot();
  }

  // Love begins with being modular.
}
