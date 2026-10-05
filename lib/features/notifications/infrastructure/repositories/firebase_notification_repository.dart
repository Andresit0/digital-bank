import '../../domain/entities/notification_intent.dart';
import '../../domain/entities/notification_message.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/firebase_messaging_data_source.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(this._dataSource);

  final FirebaseMessagingDataSource _dataSource;

  @override
  Future<bool> requestPermission() => _dataSource.requestPermission();

  @override
  Future<String?> getToken() => _dataSource.getToken();

  @override
  Stream<String> refreshToken() => _dataSource.refreshToken();

  @override
  Stream<NotificationMessage> onMessage() => _dataSource.onMessage();

  @override
  Stream<NotificationIntent> onOpened() => _dataSource.onOpened();
}
