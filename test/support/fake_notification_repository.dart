import 'dart:async';

import 'package:digital_bank/features/notifications/domain/entities/notification_intent.dart';
import 'package:digital_bank/features/notifications/domain/entities/notification_message.dart';
import 'package:digital_bank/features/notifications/domain/repositories/notification_repository.dart';

class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({
    this.permissionGranted = true,
    this.token = 'fake-fcm-registration-token',
  });

  bool permissionGranted;
  String? token;
  int permissionRequests = 0;

  final _refresh = StreamController<String>.broadcast();
  final _messages = StreamController<NotificationMessage>.broadcast();
  final _opened = StreamController<NotificationIntent>.broadcast();

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Stream<String> refreshToken() => _refresh.stream;

  @override
  Stream<NotificationMessage> onMessage() => _messages.stream;

  @override
  Stream<NotificationIntent> onOpened() => _opened.stream;

  void emitTokenRefresh(String value) => _refresh.add(value);
  void emitMessage(NotificationMessage value) => _messages.add(value);
  void emitOpened(NotificationIntent value) => _opened.add(value);

  Future<void> dispose() async {
    await _refresh.close();
    await _messages.close();
    await _opened.close();
  }
}
