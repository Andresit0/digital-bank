import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'key_value_store.dart';
import 'shared_preferences_key_value_store.dart';

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => SharedPreferencesKeyValueStore(),
);
