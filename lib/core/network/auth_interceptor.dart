import 'package:dio/dio.dart';

import '../session/session_manager.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session);

  static const String _authorizationHeader = 'Authorization';

  final SessionManager _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _session.accessToken;
    if (token != null) {
      options.headers[_authorizationHeader] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _session.clear();
    }
    handler.next(err);
  }
}
