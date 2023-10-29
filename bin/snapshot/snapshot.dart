import 'chrome.dart';
import '../config_store.dart';
import 'drive.dart';

void snapshot() {
  if (ConfigStore.globalStore["SnapshotChromeData"] == "true") {
    chromeSnapshot();
  }
  if (ConfigStore.globalStore["SnapshotDriveLogin"] == "true") {
    driveSnapshot();
  }
}
