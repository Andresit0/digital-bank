import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_state.dart';
import '../../features/auth/presentation/notifiers/auth_notifier.dart';
import '../../features/notifications/presentation/notifiers/notification_notifier.dart';

final notificationBootstrapProvider = Provider<void>((ref) {
  ref.listen<AuthState>(authProvider, (_, next) {
    if (next is AuthAuthenticated) {
      ref.read(notificationProvider.notifier).start();
    }
  });

  if (ref.read(authProvider) is AuthAuthenticated) {
    ref.read(notificationProvider.notifier).start();
  }
});
