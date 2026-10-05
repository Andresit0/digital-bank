import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

abstract interface class ConnectivityChecker {
  Future<ConnectivityStatus> check();

  Stream<ConnectivityStatus> get statusChanged;
}

class ConnectivityPlusChecker implements ConnectivityChecker {
  ConnectivityPlusChecker([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<ConnectivityStatus> check() async {
    final results = await _connectivity.checkConnectivity();
    return _toStatus(results);
  }

  @override
  Stream<ConnectivityStatus> get statusChanged =>
      _connectivity.onConnectivityChanged.map(_toStatus);

  ConnectivityStatus _toStatus(List<ConnectivityResult> results) {
    final isOnline = results.any(
      (result) => result != ConnectivityResult.none,
    );
    return isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }
}
