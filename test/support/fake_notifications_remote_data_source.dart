import 'package:digital_bank/features/notifications/infrastructure/datasources/notifications_remote_data_source.dart';
import 'package:digital_bank/shared/error/app_error.dart';
import 'package:digital_bank/shared/error/result.dart';

class FakeNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  FakeNotificationsRemoteDataSource({this.fail = false});

  bool fail;
  final registered = <({String token, String platform})>[];

  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) async {
    registered.add((token: token, platform: platform));
    if (fail) {
      return const Failure<void>(NetworkError());
    }
    return const Success<void>(null);
  }
}
