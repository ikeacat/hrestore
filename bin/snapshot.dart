import 'chrome.dart';
import 'load_config.dart';

void snapshot() {
  if (ConfigStore.globalStore["SnapshotChromeData"] == "true") {
    chromeSnapshot();
  }
}
