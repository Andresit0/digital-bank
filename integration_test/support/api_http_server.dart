import 'dart:convert';
import 'dart:io';

class ApiHttpRequest {
  const ApiHttpRequest({
    required this.method,
    required this.path,
    required this.body,
    this.authorization,
  });

  final String method;
  final String path;
  final Map<String, dynamic> body;
  final String? authorization;
}

enum ApiHttpBehavior {
  success,
  invalidCredentials,
  serverError,
  closeConnection,
}

class ApiHttpServer {
  ApiHttpServer._(this._server, this._experience);

  static Future<ApiHttpServer> start({
    ApiHttpBehavior behavior = ApiHttpBehavior.success,
    String accessToken = 'test-access-token',
    Object? accounts,
    Object? movements,
    Object? experience,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final instance = ApiHttpServer._(server, experience);
    instance._listen(
      behavior: behavior,
      accessToken: accessToken,
      accounts: accounts,
      movements: movements,
    );
    return instance;
  }

  final HttpServer _server;
  Object? _experience;
  final List<ApiHttpRequest> requests = [];

  set experience(Object? value) => _experience = value;

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
          authorization: request.headers.value(HttpHeaders.authorizationHeader),
        ),
      );

      if (behavior == ApiHttpBehavior.closeConnection) {
        await request.response.close();
        return;
      }

      final path = request.uri.path;

      if (_isProtected(path) && !_hasValidBearer(request, accessToken)) {
        _respond(request, HttpStatus.unauthorized, {'message': 'unauthorized'});
        return;
      }

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
            _experience ??
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

  static bool _isProtected(String path) {
    if (path == '/auth/login') return false;
    if (path == '/accounts' || path.startsWith('/accounts/')) return true;
    if (path == '/experience/home') return true;
    return false;
  }

  static bool _hasValidBearer(HttpRequest request, String accessToken) {
    final header = request.headers.value(HttpHeaders.authorizationHeader);
    return header == 'Bearer $accessToken';
  }

  Future<void> close() => _server.close(force: true);
}
