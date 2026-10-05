import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  throw UnimplementedError(
    'notificationRepositoryProvider must be overridden with a concrete '
    'implementation (Firebase, Commit 3).',
  );
});
