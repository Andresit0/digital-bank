import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/notification_bootstrap_provider.dart';
import 'di/router/router_provider.dart';
import '../features/notifications/domain/entities/notification_intent.dart';
import '../features/notifications/domain/entities/notification_type.dart';
import '../features/notifications/presentation/notifiers/notification_notifier.dart';
import '../features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    ref.read(onboardingProvider.notifier).resolve();

    final notifier = ref.read(notificationProvider.notifier);
    notifier.onIntent = _handleIntent;
    notifier.listen();
  }

  void _handleIntent(NotificationIntent intent) {
    if (intent.type == NotificationType.movement) {
      ref.read(goRouterProvider).go(AppRoute.movements.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationBootstrapProvider);

    return MaterialApp.router(
      title: 'Digital Bank',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
