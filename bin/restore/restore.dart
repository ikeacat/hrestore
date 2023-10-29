import 'chrome.dart';
import '../load_config.dart';
import 'drive.dart';

void restore() {
  if (ConfigStore.globalStore["RestoreChromeData"] == "true") {
    chromeRestore();
  }

  if (ConfigStore.globalStore["RestoreDriveData"] == "true") {
    driveRestore();
  }
}
