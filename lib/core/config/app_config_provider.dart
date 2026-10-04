import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config.dart';

const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

final appConfigProvider = Provider<AppConfig>(
  (ref) => const AppConfig(apiBaseUrl: _apiBaseUrl),
);
