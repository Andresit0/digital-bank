import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../domain/repositories/notification_repository.dart';
import '../infrastructure/datasources/firebase_messaging_data_source.dart';
import '../infrastructure/datasources/notifications_remote_data_source.dart';
import '../infrastructure/repositories/firebase_notification_repository.dart';

final firebaseMessagingAdapterProvider = Provider<FirebaseMessagingAdapter>((
  ref,
) {
  try {
    return FirebaseMessagingAdapterImpl(FirebaseMessaging.instance);
  } catch (_) {
    return const NoopFirebaseMessagingAdapter();
  }
});

final firebaseMessagingDataSourceProvider =
    Provider<FirebaseMessagingDataSource>(
      (ref) => FirebaseMessagingDataSourceImpl(
        ref.watch(firebaseMessagingAdapterProvider),
      ),
    );

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => FirebaseNotificationRepository(
    ref.watch(firebaseMessagingDataSourceProvider),
  ),
);

final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>(
      (ref) => NotificationsRemoteDataSourceImpl(ref.watch(httpClientProvider)),
    );
