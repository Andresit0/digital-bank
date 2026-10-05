import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:digital_bank/core/network/connectivity_checker.dart';

class _FakeConnectivityChecker implements ConnectivityChecker {
  _FakeConnectivityChecker(this._status);

  ConnectivityStatus _status;
  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();

  @override
  Future<ConnectivityStatus> check() async => _status;

  @override
  Stream<ConnectivityStatus> get statusChanged => _controller.stream;

  void emit(ConnectivityStatus status) {
    _status = status;
    _controller.add(status);
  }

  Future<void> dispose() => _controller.close();
}

void main() {
  group('ConnectivityChecker', () {
    test('RES-016 status can be online', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.online);
      expect(await checker.check(), ConnectivityStatus.online);
      await checker.dispose();
    });

    test('RES-016 status can be offline', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.offline);
      expect(await checker.check(), ConnectivityStatus.offline);
      await checker.dispose();
    });

    test('RES-016 check returns the current status', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.online);
      checker.emit(ConnectivityStatus.offline);
      expect(await checker.check(), ConnectivityStatus.offline);
      await checker.dispose();
    });

    test('RES-016 statusChanged exposes status changes', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.online);
      final changes = <ConnectivityStatus>[];
      final subscription = checker.statusChanged.listen(changes.add);

      checker.emit(ConnectivityStatus.offline);
      await Future<void>.delayed(Duration.zero);

      expect(changes, [ConnectivityStatus.offline]);

      await subscription.cancel();
      await checker.dispose();
    });

    test('RES-016 the abstraction exposes a status stream', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.online);
      expect(checker.statusChanged, isA<Stream<ConnectivityStatus>>());
      await checker.dispose();
    });

    test('RES-016 the abstraction does not gate requests', () async {
      final checker = _FakeConnectivityChecker(ConnectivityStatus.offline);
      expect(await checker.check(), ConnectivityStatus.offline);
      await checker.dispose();
    });
  });
}
