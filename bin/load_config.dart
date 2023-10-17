import 'dart:io';

class ConfigStore {
  ConfigStore({required this.origin});

  static Map<String, String>? _globalStore;
  static Map<String, String> get globalStore {
    return _globalStore ?? Map.unmodifiable({});
  }

  void commit() {
    _globalStore = Map.unmodifiable(_store);
  }

  void copy() {
    _store = Map.from(globalStore);
  }

  String origin;

  Map<String, String> _store = {};
  Map<String, String> get store => _store;

  bool safetyAdd(String key, String value) {
    if (_store.containsKey(key)) {
      return false;
    }
    _store[key] = value;
    return true;
  }

  void add(String key, String value) => _store[key] = value;
  String? remove(String key) => _store.remove(key); // passthrough func
  void clear() => _store.clear(); // passthrough func
  String? getValue(String key) => _store[key];

  Future<int> load() async {
    File forigin = File(origin);

    if (!await forigin.exists()) {
      return 0;
    }

    int count = 0;

    List<String> contents = await forigin.readAsLines();
    for (String line in contents) {
      if (line.trim().isEmpty || line.trim().startsWith("#")) {
        continue;
      }
      count++;

      List<String> lex = line.split(" ");
      String key = lex.first;

      int i = 1;
      String value = "";
      for (i; i < lex.length; i++) {
        value += "${lex[i]} ";
      }
      value = value.trim();

      bool addOp = safetyAdd(key, value);
      if (addOp) {
        count++;
      }
    }

    return count;
  }

  @override
  String toString() {
    return _store.toString();
  }
}
