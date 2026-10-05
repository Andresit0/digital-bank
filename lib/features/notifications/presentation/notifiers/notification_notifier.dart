import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/notification_providers.dart';
import '../../domain/entities/notification_intent.dart';
import '../../domain/entities/notification_message.dart';
import '../../domain/errors/notification_error.dart';
import '../notification_state.dart';

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends Notifier<NotificationState> {
  void Function(NotificationIntent intent)? onIntent;

  StreamSubscription<NotificationMessage>? _messageSubscription;
  StreamSubscription<NotificationIntent>? _openedSubscription;

  @override
  NotificationState build() {
    ref.onDispose(() {
      _messageSubscription?.cancel();
      _openedSubscription?.cancel();
    });
    return const NotificationInitial();
  }

  Future<bool> requestPermission() async {
    state = const NotificationPermissionPending();

    final granted = await ref
        .read(notificationRepositoryProvider)
        .requestPermission();

    if (!granted) {
      state = const NotificationFailure(NotificationError.permissionDenied);
    } else {
      state = const NotificationInitial();
    }

    return granted;
  }

  Future<void> loadToken() async {
    final token = await ref.read(notificationRepositoryProvider).getToken();

    if (token == null) {
      state = const NotificationFailure(NotificationError.unavailable);
    }
  }

  void listen() {
    final repository = ref.read(notificationRepositoryProvider);

    _messageSubscription?.cancel();
    _messageSubscription = repository.onMessage().listen((message) {
      state = NotificationReceived(message);
    });

    _openedSubscription?.cancel();
    _openedSubscription = repository.onOpened().listen((intent) {
      onIntent?.call(intent);
    });
  }
}
