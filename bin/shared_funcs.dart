import 'dart:io';

(int, dynamic, dynamic) copyDirectorySync(String from, String to) {
  final moveProc = Process.runSync("xcopy", ["/E", "/I", "/Y", from, to]);
  return (moveProc.exitCode, moveProc.stdout, moveProc.stderr);
}
