import 'dart:async';

import 'package:digital_bank/features/notifications/infrastructure/datasources/firebase_messaging_data_source.dart';

class FakeFirebaseMessagingAdapter implements FirebaseMessagingAdapter {
  FakeFirebaseMessagingAdapter({this.permissionGranted = true, this.token});

  bool permissionGranted;
  String? token;

  final _tokenRefresh = _Broadcast<String>();
  final _onMessage = _Broadcast<NotificationPayload>();
  final _onOpened = _Broadcast<NotificationPayload>();

  NotificationPayload? initialMessage;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> get onTokenRefresh => _tokenRefresh.stream;

  @override
  Stream<NotificationPayload> get onMessage => _onMessage.stream;

  @override
  Stream<NotificationPayload> get onMessageOpenedApp => _onOpened.stream;

  @override
  Future<NotificationPayload?> getInitialMessage() async => initialMessage;

  void emitTokenRefresh(String value) => _tokenRefresh.controller.add(value);
  void emitMessage(NotificationPayload value) =>
      _onMessage.controller.add(value);
  void emitOpened(NotificationPayload value) => _onOpened.controller.add(value);
}

class _Broadcast<T> {
  final controller = StreamController<T>.broadcast();
  Stream<T> get stream => controller.stream;
}
