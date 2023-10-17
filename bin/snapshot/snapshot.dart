import 'chrome.dart';
import '../load_config.dart';
import 'drive.dart';

void snapshot() {
  if (ConfigStore.globalStore["SnapshotChromeData"] == "true") {
    chromeSnapshot();
  }
  if (ConfigStore.globalStore["SnapshotDriveLogin"] == "true") {
    driveSnapshot();
  }
}
