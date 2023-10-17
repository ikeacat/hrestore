import 'dart:io';

import 'load_config.dart';
import 'restore.dart';
import 'snapshot.dart';

void main(List<String> arguments) async {
  print("HRestore v1.0.0 \"Initial Release\" (September 9, 2023)");
  print("Made with love by Mason\n");

  if (!Platform.isWindows) {
    print("HRestore is only supported on Windows, sorry!");
    exit(1);
  }

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
