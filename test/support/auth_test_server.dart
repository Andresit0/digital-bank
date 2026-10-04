import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class AuthTestRequest {
  const AuthTestRequest({
    required this.method,
    required this.path,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
}

enum AuthTestServerBehavior {
  success,
  invalidCredentials,
  serverError,
  closeConnection,
}

class AuthTestServer implements HttpClientAdapter {
  AuthTestServer._({required this.behavior, required this.accessToken});

  factory AuthTestServer.success({String accessToken = 'test-access-token'}) {
    return AuthTestServer._(
      behavior: AuthTestServerBehavior.success,
      accessToken: accessToken,
    );
  }

  factory AuthTestServer.invalidCredentials() {
    return AuthTestServer._(
      behavior: AuthTestServerBehavior.invalidCredentials,
      accessToken: '',
    );
  }

  factory AuthTestServer.serverError() {
    return AuthTestServer._(
      behavior: AuthTestServerBehavior.serverError,
      accessToken: '',
    );
  }

  factory AuthTestServer.closeConnection() {
    return AuthTestServer._(
      behavior: AuthTestServerBehavior.closeConnection,
      accessToken: '',
    );
  }

  final AuthTestServerBehavior behavior;
  final String accessToken;
  final List<AuthTestRequest> requests = [];

  AuthTestRequest? get lastRequest => requests.isEmpty ? null : requests.last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(
      AuthTestRequest(
        method: options.method,
        path: options.path,
        body: Map<String, dynamic>.from(options.data as Map? ?? const {}),
      ),
    );

    switch (behavior) {
      case AuthTestServerBehavior.closeConnection:
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'connection failed',
        );
      case AuthTestServerBehavior.invalidCredentials:
        return ResponseBody.fromString(
          jsonEncode({'message': 'Unauthorized'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      case AuthTestServerBehavior.serverError:
        return ResponseBody.fromString(
          jsonEncode({'message': 'Internal Server Error'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      case AuthTestServerBehavior.success:
        return ResponseBody.fromString(
          jsonEncode({'accessToken': accessToken}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
    }
  }

  @override
  void close({bool force = false}) {}
}
