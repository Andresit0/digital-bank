import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';
import '../services/observability/observability_provider.dart';
import '../session/session_providers.dart';
import 'auth_interceptor.dart';
import 'dio_http_client.dart';
import 'http_client.dart';
import 'read_cache.dart';
import 'retry_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final session = ref.watch(sessionManagerProvider);
  final observability = ref.watch(observabilityProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(session));
  dio.interceptors.add(
    RetryInterceptor(dio: dio, observability: observability),
  );
  return dio;
});

final readCacheProvider = Provider<ReadCache>((ref) => ReadCache());

final httpClientProvider = Provider<HttpClient>((ref) {
  return DioHttpClient(ref.watch(dioProvider));
});
