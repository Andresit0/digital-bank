import 'dart:convert';
import 'dart:io';

class ApiHttpRequest {
  const ApiHttpRequest({
    required this.method,
    required this.path,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
}

enum ApiHttpBehavior {
  success,
  invalidCredentials,
  serverError,
  closeConnection,
}

class ApiHttpServer {
  ApiHttpServer._(this._server);

  static Future<ApiHttpServer> start({
    ApiHttpBehavior behavior = ApiHttpBehavior.success,
    String accessToken = 'test-access-token',
    Object? accounts,
    Object? movements,
    Object? experience,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final instance = ApiHttpServer._(server);
    instance._listen(
      behavior: behavior,
      accessToken: accessToken,
      accounts: accounts,
      movements: movements,
      experience: experience,
    );
    return instance;
  }

  final HttpServer _server;
  final List<ApiHttpRequest> requests = [];

  int get port => _server.port;

  String get baseUrl => 'http://127.0.0.1:$port';

  ApiHttpRequest? get lastRequest => requests.isEmpty ? null : requests.last;

  ApiHttpRequest? requestFor(String path) {
    for (final request in requests.reversed) {
      if (request.path == path) return request;
    }
    return null;
  }

  void _listen({
    required ApiHttpBehavior behavior,
    required String accessToken,
    required Object? accounts,
    required Object? movements,
    required Object? experience,
  }) {
    _server.listen((request) async {
      final bodyText = await utf8.decoder.bind(request).join();
      final body = bodyText.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(bodyText) as Map<String, dynamic>;
      requests.add(
        ApiHttpRequest(
          method: request.method,
          path: request.uri.path,
          body: body,
        ),
      );

      if (behavior == ApiHttpBehavior.closeConnection) {
        await request.response.close();
        return;
      }

      final path = request.uri.path;

      if (path.startsWith('/accounts/') && path.endsWith('/movements')) {
        _respond(request, HttpStatus.ok, movements ?? const <dynamic>[]);
        return;
      }

      switch (path) {
        case '/auth/login':
          _respond(
            request,
            behavior == ApiHttpBehavior.invalidCredentials
                ? HttpStatus.unauthorized
                : behavior == ApiHttpBehavior.serverError
                ? HttpStatus.internalServerError
                : HttpStatus.ok,
            behavior == ApiHttpBehavior.success
                ? {'accessToken': accessToken}
                : {'message': 'error'},
          );
          break;
        case '/accounts':
          _respond(request, HttpStatus.ok, accounts ?? const <dynamic>[]);
          break;
        case '/experience/home':
          _respond(
            request,
            HttpStatus.ok,
            experience ??
                {
                  'experience': 'account_home',
                  'version': 1,
                  'sections': <dynamic>[],
                },
          );
          break;
        default:
          _respond(request, HttpStatus.notFound, {'message': 'not found'});
      }
    });
  }

  void _respond(HttpRequest request, int statusCode, Object? data) {
    request.response
      ..statusCode = statusCode
      ..headers.contentType = ContentType.json
      ..write(jsonEncode(data));
    request.response.close();
  }

  Future<void> close() => _server.close(force: true);
}
