import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

void main(List<String> args) async {
  if (args.isNotEmpty && args.first == "--help") {
    print("hrestore installer\n");
    print("usage: installer.exe [--latest-unstable]");
  }

  print("Looking up releases..");
  final url = Uri.https("api.github.com", "/repos/ikeacat/hrestore/releases");
  final req = await http.get(url);
  print(req.body);

  final List releases = JsonDecoder().convert(req.body);
  if (releases.isEmpty) {
    stderr.write("Failed to get releases.");
  }

  if (args.isNotEmpty && args.first == "--latest-unstable") {
    grab(releases.first).then((value) => unzip());
  }
}

Future<void> grab(Map release) async {
  print("Using ${release["name"]} (${release["published_at"]})");
  for (Map asset in release["assets"]) {
    if (asset["name"] == "skeleton.zip") {
      var url = Uri.parse(asset["browser_download_url"]);
      final resp = await http.get(url);
      print("Downloading zip...");
      File("skeleton.zip").writeAsBytesSync(resp.bodyBytes);
      return;
    }
  }
}

void unzip() {
  if (!File("skeleton.zip").existsSync()) {
    stderr.write("Failed to unzip skeleton.zip - It doesn't exist.");
    return;
  }
  print("Unzipping...");
  final unzip =
      Process.runSync("tar", ["-xvf", "skeleton.zip"], runInShell: true);
  if (unzip.exitCode != 0) {
    stderr.write(
        "Failed to unzip skeleton.zip - tar returned a non-zero exit code.");
    return;
  }
  File("skeleton.zip").deleteSync();
}
