import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entities/notification_intent.dart';
import '../../domain/entities/notification_message.dart';
import '../../domain/entities/notification_type.dart';

abstract interface class FirebaseMessagingDataSource {
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> refreshToken();

  Stream<NotificationMessage> onMessage();

  Stream<NotificationIntent> onOpened();
}

class NotificationPayload {
  const NotificationPayload({required this.type, this.movementId});

  final String? type;
  final String? movementId;
}

abstract interface class FirebaseMessagingAdapter {
  Future<bool> requestPermission();

  Future<String?> getToken();

  Stream<String> get onTokenRefresh;

  Stream<NotificationPayload> get onMessage;

  Stream<NotificationPayload> get onMessageOpenedApp;

  Future<NotificationPayload?> getInitialMessage();
}

class FirebaseMessagingAdapterImpl implements FirebaseMessagingAdapter {
  FirebaseMessagingAdapterImpl(this._messaging);

  final FirebaseMessaging _messaging;

  @override
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  @override
  Future<String?> getToken() => _messaging.getToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<NotificationPayload> get onMessage =>
      FirebaseMessaging.onMessage.map(_toPayload);

  @override
  Stream<NotificationPayload> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp.map(_toPayload);

  @override
  Future<NotificationPayload?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : _toPayload(message);
  }

  NotificationPayload _toPayload(RemoteMessage message) => NotificationPayload(
    type: message.data['type'] as String?,
    movementId: message.data['movementId'] as String?,
  );
}

class FirebaseMessagingDataSourceImpl implements FirebaseMessagingDataSource {
  FirebaseMessagingDataSourceImpl(this._adapter);

  final FirebaseMessagingAdapter _adapter;

  @override
  Future<bool> requestPermission() => _adapter.requestPermission();

  @override
  Future<String?> getToken() => _adapter.getToken();

  @override
  Stream<String> refreshToken() => _adapter.onTokenRefresh;

  @override
  Stream<NotificationMessage> onMessage() => _adapter.onMessage.map(_toMessage);

  @override
  Stream<NotificationIntent> onOpened() {
    final controller = StreamController<NotificationIntent>();
    final subscription = _adapter.onMessageOpenedApp.listen(
      (payload) => controller.add(_toIntent(payload)),
    );
    controller.onCancel = subscription.cancel;
    _adapter.getInitialMessage().then((initial) {
      if (initial != null) {
        controller.add(_toIntent(initial));
      }
    });
    return controller.stream;
  }

  NotificationMessage _toMessage(NotificationPayload payload) =>
      NotificationMessage(
        type: _typeOf(payload),
        movementId: payload.movementId,
      );

  NotificationIntent _toIntent(NotificationPayload payload) =>
      NotificationIntent(
        type: _typeOf(payload),
        movementId: payload.movementId,
      );

  NotificationType _typeOf(NotificationPayload payload) =>
      payload.type == 'movement'
      ? NotificationType.movement
      : NotificationType.unknown;
}
