import 'dart:convert';
import 'dart:io';

class AuthHttpRequest {
  const AuthHttpRequest({
    required this.method,
    required this.path,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
}

enum AuthHttpBehavior { success, invalidCredentials, serverError }

class AuthHttpServer {
  AuthHttpServer._(this._server);

  static Future<AuthHttpServer> start({
    AuthHttpBehavior behavior = AuthHttpBehavior.success,
    String accessToken = 'test-access-token',
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final instance = AuthHttpServer._(server);
    instance._listen(behavior, accessToken);
    return instance;
  }

  final HttpServer _server;
  final List<AuthHttpRequest> requests = [];

  int get port => _server.port;

  String get baseUrl => 'http://127.0.0.1:$port';

  AuthHttpRequest? get lastRequest => requests.isEmpty ? null : requests.last;

  void _listen(AuthHttpBehavior behavior, String accessToken) {
    _server.listen((request) async {
      final bodyText = await utf8.decoder.bind(request).join();
      final body = bodyText.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyText) as Map<String, dynamic>;
      requests.add(
        AuthHttpRequest(
          method: request.method,
          path: request.uri.path,
          body: body,
        ),
      );

      switch (behavior) {
        case AuthHttpBehavior.invalidCredentials:
          request.response
            ..statusCode = HttpStatus.unauthorized
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'message': 'Unauthorized'}));
          await request.response.close();
          break;
        case AuthHttpBehavior.serverError:
          request.response
            ..statusCode = HttpStatus.internalServerError
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'message': 'Internal Server Error'}));
          await request.response.close();
          break;
        case AuthHttpBehavior.success:
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({'accessToken': accessToken}));
          await request.response.close();
          break;
      }
    });
  }

  Future<void> close() => _server.close(force: true);
}
