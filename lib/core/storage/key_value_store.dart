abstract interface class KeyValueStore {
  Future<bool?> getBool(String key);

  Future<void> setBool(String key, bool value);
}
