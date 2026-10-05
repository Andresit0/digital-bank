import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/notification_repository.dart';
import '../infrastructure/datasources/firebase_messaging_data_source.dart';
import '../infrastructure/repositories/firebase_notification_repository.dart';

final firebaseMessagingAdapterProvider = Provider<FirebaseMessagingAdapter>(
  (ref) => FirebaseMessagingAdapterImpl(FirebaseMessaging.instance),
);

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
