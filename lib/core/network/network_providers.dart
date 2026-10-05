import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config_provider.dart';
import '../session/session_providers.dart';
import 'auth_interceptor.dart';
import 'dio_http_client.dart';
import 'http_client.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final session = ref.watch(sessionManagerProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  )..interceptors.add(AuthInterceptor(session));
});

final httpClientProvider = Provider<HttpClient>((ref) {
  return DioHttpClient(ref.watch(dioProvider));
});
