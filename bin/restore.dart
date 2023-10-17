import 'chrome.dart';
import 'load_config.dart';

void restore() {
  if (ConfigStore.globalStore["RestoreChromeData"] == "true") {
    chromeRestore();
  }
}
