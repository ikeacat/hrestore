import 'chrome.dart';
import '../config_store.dart';
import 'drive.dart';

void restore() {
  if (ConfigStore.globalStore["RestoreChromeData"] == "true") {
    chromeRestore();
  }

  if (ConfigStore.globalStore["RestoreDriveData"] == "true") {
    driveRestore();
  }
}
