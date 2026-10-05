class ReadCache {
  final Map<String, Object> _entries = {};

  void put(String key, Object value) {
    _entries[key] = value;
  }

  Object? get(String key) => _entries[key];

  void clear() {
    _entries.clear();
  }
}
